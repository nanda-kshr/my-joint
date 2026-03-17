import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientTreatmentsScreen extends StatefulWidget {
  final String? patientUid;
  const PatientTreatmentsScreen({super.key, this.patientUid});

  @override
  State<PatientTreatmentsScreen> createState() => _PatientTreatmentsScreenState();
}

class _PatientTreatmentsScreenState extends State<PatientTreatmentsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _treatments = [];
  String? _userRole;
  String? _uid;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
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
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() { _isLoading = true; });
    try {
      final treatments = await _apiService.getPatientTreatments(uid: _uid);
      setState(() {
        _treatments = List<Map<String, dynamic>>.from(treatments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTreatment() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _apiService.addPatientTreatment(uid: _uid, data: {'text': _textController.text});
      _textController.clear();
      _loadTreatments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add treatment: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text(_selectedLanguage == 'en' ? 'Treatments' : 'சிகிச்சைகள்', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
      : _treatments.isEmpty
      ? Center(child: Text(_selectedLanguage == 'en' ? 'No treatments found.' : 'சிகிச்சைகள் கிடைக்கவில்லை.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _treatments.length,
                      itemBuilder: (context, index) {
                        final c = _treatments[index];
                        final created = c['createdAt'] ?? c['created_at'];
                        final treatment = c['treatment'] ?? c['Treatment'] ?? c['text'] ?? 'No treatment';
                        final name = c['name'] ?? c['Name'];
                        final dose = c['dose'] ?? c['Dose'];
                        final route = c['route'] ?? c['Route'];
                        final frequencyText = c['frequency_text'] ?? c['frequencyText'] ?? c['Frequency_text'];
                        final timePeriod = c['Time_Period'] ?? c['time_period'] ?? c['timePeriod'];

                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.healing, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    Text(_selectedLanguage == 'en' ? 'Treatment' : 'சிகிச்சை', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.teal)),
                                    const Spacer(),
                                    if (created != null)
                                      Text(
                                        created.toString().split('T').first,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text('$treatment${name != null ? ' - ' + name : ''}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                                Text(_selectedLanguage == 'en' ? 'Dose: ${dose ?? 'No data'}' : 'மாத்திரை: ${dose ?? 'No data'}'),
                                Text(_selectedLanguage == 'en' ? 'Route: ${route ?? 'No data'}' : 'முறை: ${route ?? 'No data'}'),
                                Text(_selectedLanguage == 'en' ? 'Frequency: ${frequencyText ?? 'No data'}' : 'அதிகமா: ${frequencyText ?? 'No data'}'),
                                Text(_selectedLanguage == 'en' ? 'Duration: ${timePeriod ?? 'No data'}' : 'காலம்: ${timePeriod ?? 'No data'}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 