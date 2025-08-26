import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDailyAssessmentScreen extends StatefulWidget {
  final int patientUid;
  const PatientDailyAssessmentScreen({Key? key, required this.patientUid}) : super(key: key);

  @override
  State<PatientDailyAssessmentScreen> createState() => _PatientDailyAssessmentScreenState();
}

class _PatientDailyAssessmentScreenState extends State<PatientDailyAssessmentScreen> {
  double _painScore = 5;
  bool _isSavingPain = false;
  List<Map<String, dynamic>> _painScores = [];
  late ApiService _apiService;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeApiService();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() { _selectedLanguage = prefs.getString('language') ?? 'en'; });
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_selectedLanguage == 'en' ? 'Pain score saved!' : 'வலி மதிப்பீடு சேமிக்கப்பட்டது!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_selectedLanguage == 'en' ? 'Failed to save pain score' : 'வலி மதிப்பீட்டை சேமிக்க முடியவில்லை'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isSavingPain = false; });
    }
  }

  Future<void> _fetchPainAssessments() async {
    try {
      final scores = await _apiService.getPainAssessments(patientId: widget.patientUid);
      setState(() { _painScores = List<Map<String, dynamic>>.from(scores); });
    } catch (e) {
      // ignore
    }
  }

  List<FlSpot> _getPainSpots() {
    final sorted = List<Map<String, dynamic>>.from(_painScores);
    sorted.sort((a, b) {
      final da = DateTime.tryParse(a['recorded_at']?.toString() ?? '') ?? DateTime.now();
      final db = DateTime.tryParse(b['recorded_at']?.toString() ?? '') ?? DateTime.now();
      return da.compareTo(db);
    });

    final last12 = sorted.length > 12 ? sorted.sublist(sorted.length - 12) : sorted;

    return last12.asMap().entries.map((entry) {
      final idx = entry.key;
      final data = entry.value;
      final scoreVal = data['pain_score'] ?? data['painScore'] ?? data['score'];
      final y = double.tryParse(scoreVal?.toString() ?? '') ?? 0.0;
      return FlSpot(idx.toDouble(), y);
    }).toList();
  }

  Widget _buildPainChart(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return Center(child: Text(_selectedLanguage == 'en' ? 'No chart data' : 'வரைவியல் தரவு இல்லை'));
    }

    final textColor = Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 10,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < spots.length) {
                    // try to read date text from _painScores aligned with spots
                    final raw = _painScores.length > spots.length
                        ? _painScores.sublist(_painScores.length - spots.length)[index]
                        : _painScores[index];
                    final dateStr = raw['recorded_at']?.toString() ?? '';
                    final date = DateTime.tryParse(dateStr);
                    final label = date != null ? DateFormat.Md().format(date) : '';
                    return SideTitleWidget(meta: meta, space: 6, child: Text(label, style: TextStyle(color: textColor, fontSize: 10)));
                  }
                  return Container();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // show only integer labels (0,1,2,...10)
                  final v = value;
                  final isInteger = (v - v.round()).abs() < 0.001;
                  if (!isInteger) return Container();
                  return Text(v.toInt().toString(), style: TextStyle(color: textColor, fontSize: 10));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.redAccent,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.15)),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((t) {
                  final idx = t.spotIndex;
                  final raw = _painScores.length > spots.length
                      ? _painScores.sublist(_painScores.length - spots.length)[idx]
                      : _painScores[idx];
                  final date = DateTime.tryParse(raw['recorded_at']?.toString() ?? '');
                  final dateText = date != null ? DateFormat.yMd().add_jm().format(date) : '';
                  return LineTooltipItem('${t.y.toStringAsFixed(1)}\n$dateText', TextStyle(color: Colors.black));
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = _selectedLanguage == 'en';
    return Scaffold(
      appBar: AppBar(title: Text(isEn ? 'Daily Pain Assessment' : 'தினசரி வலி மதிப்பீடு')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEn ? 'How much pain are you in today?' : 'இன்று நீங்கள் எவ்வளவு வலியில் இருக்கிறீர்கள்?', style: const TextStyle(fontSize: 16)),
            Slider(
              value: _painScore,
              min: 0,
              max: 10,
              divisions: 20,
              label: _painScore.toStringAsFixed(1),
              onChanged: _isSavingPain ? null : (value) => setState(() => _painScore = value),
            ),
            const SizedBox(height: 8),
            // Integer tick labels under the slider (0..10)
            Row(
              children: List.generate(11, (i) {
                return Expanded(
                  child: Text(
                    i.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                );
              }),
            ),
            ElevatedButton(
              onPressed: _isSavingPain ? null : _savePainAssessment,
              child: _isSavingPain ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text(isEn ? 'Save' : 'சேமி'),
            ),
            const SizedBox(height: 24),
            // Pain chart (range 0-10, 0.5 steps)
            _buildPainChart(_getPainSpots()),
            const SizedBox(height: 16),
            Text(isEn ? 'Recent pain entries' : 'சமீபத்திய வலி பதிவுகள்', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _painScores.isEmpty
                  ? Center(child: Text(isEn ? 'No data' : 'தகவல்கள் இல்லை'))
                  : ListView.separated(
                      itemCount: _painScores.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final e = _painScores[index];
                        final date = e['recorded_at']?.toString() ?? '';
                        final score = e['pain_score']?.toString() ?? '';
                        return ListTile(
                          leading: const Icon(Icons.favorite, color: Colors.redAccent),
                          title: Text(isEn ? 'Pain: $score' : 'வலி: $score'),
                          subtitle: Text(date),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

