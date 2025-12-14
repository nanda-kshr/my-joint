import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'das28_sdai_flow.dart';

class PatientDiseaseScoresScreen extends StatefulWidget {
  final String? patientUid;
  const PatientDiseaseScoresScreen({super.key, this.patientUid});

  @override
  State<PatientDiseaseScoresScreen> createState() => _PatientDiseaseScoresScreenState();
}

class _PatientDiseaseScoresScreenState extends State<PatientDiseaseScoresScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _diseaseScores = [];
  String? _userRole;
  String? _uid;
  final _formKey = GlobalKey<FormState>();
  final _sdaiController = TextEditingController();
  final _das28crpController = TextEditingController();
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeApiService();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _userRole = await _apiService.getUserType();
    _uid = widget.patientUid ?? await _apiService.getUserId() ?? '';
    _loadDiseaseScores();
  }

  Future<void> _loadDiseaseScores() async {
    setState(() { _isLoading = true; });
    try {
      final diseaseScores = await _apiService.getPatientDiseaseScores(uid: widget.patientUid ?? _uid);
      print('Disease scores loaded: ${diseaseScores.length} items');
      if (diseaseScores.isNotEmpty) {
        print('First score: ${diseaseScores[0]}');
      }
      setState(() {
        _diseaseScores = List<Map<String, dynamic>>.from(diseaseScores);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading disease scores: $e');
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _addDiseaseScore() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final sdai = double.parse(_sdaiController.text);
      final das28crp = double.parse(_das28crpController.text);
      await _apiService.addPatientDiseaseScore(
        uid: widget.patientUid ?? _uid,
        sdai: sdai,
        das28crp: das28crp,
      );
      _sdaiController.clear();
      _das28crpController.clear();
      _loadDiseaseScores();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disease score added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add disease score: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteDiseaseScore(int id) async {
    try {
      await _apiService.deletePatientDiseaseScore(id: id);
      _loadDiseaseScores();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Disease score deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete disease score: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _sdaiController.dispose();
    _das28crpController.dispose();
    super.dispose();
  }

  Color _getSdaiColor(double score) {
    if (score <= 3.3) return Colors.green; // Remission
    if (score <= 11.0) return Colors.blue; // Low Activity
    if (score <= 26.0) return Colors.orange; // Moderate Activity
    return Colors.red; // High Activity
  }

  Color _getDas28CrpColor(double score) {
    if (score <= 2.6) return Colors.green; // Remission
    if (score <= 3.2) return Colors.blue; // Low Activity
    if (score <= 5.1) return Colors.orange; // Moderate Activity
    return Colors.red; // High Activity
  }

  Widget _buildChart({
    required List<FlSpot> spots,
    required double maxY,
    required String title,
    required Map<String, double> thresholds,
    required Color Function(double) colorFunction,
  }) {
    if (spots.isEmpty) {
      return Center(child: Text('No data available for $title'));
    }

    final sortedScores = List<Map<String, dynamic>>.from(_diseaseScores);
  sortedScores.sort((a, b) {
  final dateA = a['created_at'] != null ? DateTime.parse(a['created_at'].toString()) : DateTime(1970);
  final dateB = b['created_at'] != null ? DateTime.parse(b['created_at'].toString()) : DateTime(1970);
  return dateA.compareTo(dateB);
  });

  final last12Scores = sortedScores.length > 12
    ? sortedScores.sublist(sortedScores.length - 12)
    : sortedScores;

    final primaryColor = Theme.of(context).primaryColor;
    final textColor =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54;

    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: 0,
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
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < last12Scores.length) {
                  final dateStr = last12Scores[index]['created_at']?.toString();
                  final date = dateStr != null ? DateTime.parse(dateStr) : DateTime(1970);
                  // MongoDB ISODate format
                  final mongoDate = date.toUtc().toIso8601String();
                  return SideTitleWidget(
                    meta: meta,
                    space: 8.0,
                    child: Text(mongoDate.substring(0, 10),
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10)),
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
                  value.toStringAsFixed(1),
                  style: TextStyle(color: textColor, fontSize: 10),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: colorFunction(spot.y),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.3),
                  primaryColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          horizontalLines: thresholds.entries.map((entry) {
            return HorizontalLine(
              y: entry.value,
              color: Colors.grey.withOpacity(0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => entry.key,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            );
          }).toList(),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final scoreData = last12Scores[spot.spotIndex];
                final dateStr = scoreData['created_at']?.toString();
                final date = dateStr != null ? DateTime.parse(dateStr) : DateTime(1970);
                final mongoDate = date.toUtc().toIso8601String();
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)}\n$mongoDate',
                  TextStyle(
                      color: colorFunction(spot.y), fontWeight: FontWeight.bold),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(_selectedLanguage == 'en' ? 'Disease Scores' : 'நோய் மதிப்பீடுகள்', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      floatingActionButton: _userRole == 'doctor'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Das28SdaiFlowScreen()),
                );
              },
              tooltip: 'Add Disease Score',
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDiseaseScores,
                        child: Text(_selectedLanguage == 'en' ? 'Retry' : 'மீண்டும்'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_diseaseScores.isNotEmpty) ...[
                        Text('SDAI Score Over Time',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: _buildChart(
                            spots: _getSpots('SDAI', 'sdai'),
                            maxY: 100,
                            title: 'SDAI',
                            thresholds: {
                              'High': 26.0,
                              'Moderate': 11.0,
                              'Low': 3.3,
                            },
                            colorFunction: _getSdaiColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildLegend(
                          {
                            'High Activity (>26.0)': Colors.red,
                            'Moderate Activity (11.1-26.0)': Colors.orange,
                            'Low Activity (3.4-11.0)': Colors.blue,
                            'Remission (<=3.3)': Colors.green,
                          },
                        ),
                        const SizedBox(height: 40),
                        Text('DAS28-CRP Score Over Time',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 300,
                          child: _buildChart(
                            spots: _getSpots('DAS_28_CRP', 'das_28_crp'),
                            maxY: 10,
                            title: 'DAS28-CRP',
                            thresholds: {
                              'High': 5.1,
                              'Moderate': 3.2,
                              'Low': 2.6,
                            },
                            colorFunction: _getDas28CrpColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildLegend(
                          {
                            'High Activity (>5.1)': Colors.red,
                            'Moderate Activity (3.3-5.1)': Colors.orange,
                            'Low Activity (2.7-3.2)': Colors.blue,
                            'Remission (<=2.6)': Colors.green,
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                      if (_diseaseScores.isEmpty)
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics,
                                  size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                'No disease scores found.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        const SizedBox(height: 20),
                        Text('Disease Score History',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _diseaseScores.length,
                          itemBuilder: (context, index) {
                            final score = _diseaseScores[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                title: const Text('Disease Score', style: TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('SDAI: ${score['SDAI'] ?? score['sdai'] ?? 'N/A'}'),
                                    Text('DAS28-CRP: ${score['DAS_28_CRP'] ?? score['das_28_crp'] ?? 'N/A'}'),
                                    Text(
                                      'Date: ${score['created_at'] != null ? DateTime.parse(score['created_at'].toString()).toUtc().toIso8601String() : 'Unknown'}',
                                    ),
                                  ],
                                ),
                                trailing: _userRole == 'doctor'
                                    ? IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Disease Score'),
                                              content: const Text('Are you sure you want to delete this disease score?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteDiseaseScore(score['id']);
                                                  },
                                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ]
                    ],
                  ),
                ),
    );
  }

  Widget _buildLegend(Map<String, Color> colorMap) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: colorMap.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              color: entry.value,
            ),
            const SizedBox(width: 4),
            Text(entry.key, style: const TextStyle(fontSize: 10)),
          ],
        );
      }).toList(),
    );
  }

  List<FlSpot> _getSpots(String key1, String key2) {
    final sortedScores = List<Map<String, dynamic>>.from(_diseaseScores);
    sortedScores.sort((a, b) {
      final dateA = a['created_at'] != null ? DateTime.parse(a['created_at'].toString()) : DateTime(1970);
      final dateB = b['created_at'] != null ? DateTime.parse(b['created_at'].toString()) : DateTime(1970);
      return dateA.compareTo(dateB);
    });

    final last12Scores = sortedScores.length > 12
        ? sortedScores.sublist(sortedScores.length - 12)
        : sortedScores;

    print('Getting spots for keys: $key1, $key2');
    print('Number of scores: ${last12Scores.length}');
    
    final spots = last12Scores.asMap().entries.map((entry) {
      final index = entry.key;
      final scoreData = entry.value;
      final scoreValue = scoreData[key1] ?? scoreData[key2];
      print('Index $index: $scoreData -> scoreValue: $scoreValue');
      if (scoreValue != null) {
        return FlSpot(
            index.toDouble(), double.parse(scoreValue.toString()));
      }
      return null;
    }).whereType<FlSpot>().toList();
    
    print('Generated ${spots.length} spots');
    return spots;
  }
}