import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PainAssessmentScreen extends StatefulWidget {
  final String patientUid;
  const PainAssessmentScreen({Key? key, required this.patientUid}) : super(key: key);

  @override
  State<PainAssessmentScreen> createState() => _PainAssessmentScreenState();
}

class _PainAssessmentScreenState extends State<PainAssessmentScreen> {
  double _painScore = 5;
  bool _isSavingPain = false;
  List<Map<String, dynamic>> _painScores = [];
  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    await _fetchPainAssessments();
  }

  Future<void> _savePainAssessment() async {
    setState(() { _isSavingPain = true; });
    try {
      await _apiService.savePainAssessment(patientId: widget.patientUid, painScore: _painScore.round());
      await _fetchPainAssessments();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pain score saved!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save pain score'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isSavingPain = false; });
    }
  }

  Future<void> _fetchPainAssessments() async {
    try {
      final scores = await _apiService.getPainAssessments(patientId: widget.patientUid);
      setState(() {
        _painScores = List<Map<String, dynamic>>.from(scores);
      });
    } catch (e) {
      // ignore error for now
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Pain Assessment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('How much pain are you in today?', style: TextStyle(fontSize: 16)),
            Slider(
              value: _painScore,
              min: 0,
              max: 10,
              divisions: 10,
              label: _painScore.round().toString(),
              onChanged: _isSavingPain ? null : (value) {
                setState(() {
                  _painScore = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _isSavingPain ? null : _savePainAssessment,
              child: _isSavingPain ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'),
            ),
            const SizedBox(height: 32),
            const Text('Last 10 pain scores:', style: TextStyle(fontSize: 16)),
            SizedBox(
              height: 120,
              child: _painScores.isEmpty
                  ? const Center(child: Text('No data'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomPaint(
                        painter: PainChartPainter(_painScores),
                        child: Container(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class PainChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> scores;
  PainChartPainter(this.scores);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    if (scores.isEmpty) return;
    const maxScore = 10.0;
    final points = <Offset>[];
    for (int i = 0; i < scores.length; i++) {
      final x = size.width * i / (scores.length - 1);
      final y = size.height * (1 - (scores[i]['pain_score'] / maxScore));
      points.add(Offset(x, y));
    }
    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }
    // Draw axis
    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint);
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
