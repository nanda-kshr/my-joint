import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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
        SnackBar(content: Text('Pain score saved!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save pain score'), backgroundColor: Colors.red),
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
      appBar: AppBar(title: Text('Daily Pain Assessment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('How much pain are you in today?', style: TextStyle(fontSize: 16)),
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
              child: _isSavingPain ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Text('Save'),
            ),
            const SizedBox(height: 32),
            Text('Last 10 pain scores:', style: TextStyle(fontSize: 16)),
            Container(
              height: 220,
              child: _painScores.isEmpty
                  ? Center(child: Text('No data'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 10,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.withOpacity(0.2),
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < _painScores.length) {
                                    final date = DateTime.parse(_painScores[index]['recorded_at']);
                                    return SideTitleWidget(
                                      meta: meta,
                                      space: 8.0,
                                      child: Text(DateFormat.Md().format(date),
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value == meta.max) {
                                    return Container();
                                  }
                                  return Text(
                                    value.toStringAsFixed(0),
                                    style: const TextStyle(color: Colors.black, fontSize: 12),
                                    textAlign: TextAlign.left,
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getPainSpots(),
                              isCurved: true,
                              preventCurveOverShooting: true,
                              color: Colors.deepPurple,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.deepPurple,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.deepPurple.withOpacity(0.3),
                                    Colors.deepPurple.withOpacity(0.0),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final scoreData = _painScores[spot.spotIndex];
                                  final date = DateTime.parse(scoreData['recorded_at']);
                                  return LineTooltipItem(
                                    '${spot.y.toStringAsFixed(0)}\n${DateFormat.yMd().format(date)}',
                                    const TextStyle(
                                        color: Colors.deepPurple, fontWeight: FontWeight.bold),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getPainSpots() {
    final sortedScores = List<Map<String, dynamic>>.from(_painScores);
    sortedScores.sort((a, b) {
      final dateA = DateTime.parse(a['recorded_at']);
      final dateB = DateTime.parse(b['recorded_at']);
      return dateA.compareTo(dateB);
    });
    final lastScores = sortedScores.length > 10
        ? sortedScores.sublist(sortedScores.length - 10)
        : sortedScores;
    return lastScores.asMap().entries.map((entry) {
      final index = entry.key;
      final scoreData = entry.value;
      final scoreValue = scoreData['pain_score'];
      if (scoreValue != null) {
        return FlSpot(index.toDouble(), double.parse(scoreValue.toString()));
      }
      return null;
    }).whereType<FlSpot>().toList();
  }
}
