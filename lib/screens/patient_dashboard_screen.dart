import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'patient_complaints_screen.dart';
import 'patient_comorbidities_screen.dart';
// ...existing code...
import 'patient_medications_screen.dart';
import 'patient_investigations_screen.dart';
import 'patient_treatments_screen.dart';

// temp_screen.dart import removed
import 'consult_now_screen.dart';
// health_records_screen.dart removed per request (health records UI disabled)
import 'diet_screen.dart';
import 'exercise_screen.dart';
import 'patient_daily_assessment_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();

}

// ...existing code...

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userData;
  String _selectedLanguage = 'en'; // 'en' or 'ta'

  @override
  void initState() {
  super.initState();
  _initializeApiService();
  _loadLanguage();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadUserData();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }


  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getPatientProfile();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await _apiService.clearStoredData();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(_userData?['name'] ?? (_selectedLanguage == 'en' ? 'Patient Dashboard' : 'நோயாளர் டாஷ்போர்டு'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: _selectedLanguage == 'en' ? 'Settings' : 'அமைப்புகள்',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: _selectedLanguage == 'en' ? 'Logout' : 'வெளியேறு',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        child: Text(_selectedLanguage == 'en' ? 'Retry' : 'மீண்டும் முயற்சி'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(_userData?['name'] ?? (_selectedLanguage == 'en' ? 'Patient' : 'நோயாளர்'), style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(_userData?['email'] ?? '', style: const TextStyle(color: Colors.black54)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Complaints' : 'புகார்கள்',
                            Icons.note_add,
                            Colors.blue,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientComplaintsScreen(patientUid: _userData?['uid']),
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Comorbidities' : 'இணை நோய்கள்',
                            Icons.medical_services,
                            Colors.orange,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientComorbiditiesScreen(patientUid: _userData?['uid']),
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Daily Assessment' : 'தினசரி மதிப்பீடு',
                            Icons.assessment,
                            Colors.deepPurple,
                            () {
                              final rawUid = _userData?['uid'] ?? _userData?['_id'] ?? _userData?['id'];
                              final uid = rawUid != null ? rawUid.toString() : null;
                              if (uid != null && uid.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDailyAssessmentScreen(patientUid: uid),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(_selectedLanguage == 'en' ? 'Patient id missing' : 'நோயாளர் ஐடி இல்லை')),
                                );
                              }
                            },
                          ),



// ...existing code...
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Medications' : 'மருந்துகள்',
                            Icons.medication,
                            Colors.purple,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientMedicationsScreen(patientUid: _userData?['uid']),
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Investigations' : 'ஆய்வுகள்',
                            Icons.science,
                            Colors.teal,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientInvestigationsScreen(patientUid: _userData?['uid']),
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Treatments' : 'சிகிச்சைகள்',
                            Icons.healing,
                            Colors.indigo,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientTreatmentsScreen(patientUid: _userData?['uid']),
                              ),
                            ),
                          ),
                          // New cards
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Diet' : 'உணவு',
                            Icons.restaurant,
                            Colors.redAccent,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DietScreen(),
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Exercises' : 'உடற்பயிற்சி',
                            Icons.fitness_center,
                            Colors.lightGreen,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ExerciseScreen(),
                              ),
                            ),
                          ),
                          // Health Records card removed
                          _buildDashboardItem(
                            context,
                            _selectedLanguage == 'en' ? 'Consult Now' : 'இப்போது ஆலோசனை',
                            Icons.support_agent,
                            Colors.cyan,
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ConsultNowScreen(),
                              ),
                            ),
                          ),
                          // Referrals screen not available for patients
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}

// Simple line chart painter for pain scores
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
    final maxScore = 10.0;
    final minScore = 0.0;
  final leftPadding = 48.0;
  final bottomPadding = 32.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding;

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.5;
    // Y axis
    canvas.drawLine(Offset(leftPadding, 0), Offset(leftPadding, chartHeight), axisPaint);
    // X axis
    canvas.drawLine(Offset(leftPadding, chartHeight), Offset(leftPadding + chartWidth, chartHeight), axisPaint);

  // Y axis labels (0, 5, 10) - move inside chart area and increase font size
  final labelFontSize = 16.0;
  final labelPadding = 8.0;
  final textPainter0 = _textPainter('0', fontSize: labelFontSize);
  textPainter0.paint(canvas, Offset(labelPadding, chartHeight - textPainter0.height / 2));
  final textPainter5 = _textPainter('5', fontSize: labelFontSize);
  textPainter5.paint(canvas, Offset(labelPadding, chartHeight / 2 - textPainter5.height / 2));
  final textPainter10 = _textPainter('10', fontSize: labelFontSize);
  textPainter10.paint(canvas, Offset(labelPadding, -textPainter10.height / 2));

    // Prepare points (last date to right)
    final points = <Offset>[];
    for (int i = 0; i < scores.length; i++) {
      final x = leftPadding + chartWidth * i / (scores.length - 1);
      final y = chartHeight - ((scores[i]['pain_score'] - minScore) / (maxScore - minScore)) * chartHeight;
      points.add(Offset(x, y));
    }
    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }

    // Draw date labels on x-axis (increase font size, move up if clipped)
    for (int i = 0; i < scores.length; i++) {
      final dateStr = _formatDate(scores[i]['recorded_at']);
      final tp = _textPainter(dateStr, fontSize: 14);
      final x = leftPadding + chartWidth * i / (scores.length - 1) - tp.width / 2;
      final y = chartHeight + labelPadding;
      tp.paint(canvas, Offset(x, y));
    }
  }

  TextPainter _textPainter(String text, {double fontSize = 12}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(color: Colors.black, fontSize: fontSize)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day}/${dt.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}