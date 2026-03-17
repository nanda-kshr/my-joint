import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientInvestigationsScreen extends StatefulWidget {
  final String? patientUid;
  const PatientInvestigationsScreen({super.key, this.patientUid});

  @override
  State<PatientInvestigationsScreen> createState() => _PatientInvestigationsScreenState();
}

class _PatientInvestigationsScreenState extends State<PatientInvestigationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _investigations = [];
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
    _loadInvestigations();
  }

  Future<void> _loadInvestigations() async {
    setState(() { _isLoading = true; });
    try {
      final investigations = await _apiService.getPatientInvestigations(uid: _uid);
      setState(() {
        _investigations = List<Map<String, dynamic>>.from(investigations);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addInvestigation() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _apiService.addPatientInvestigation(uid: _uid, data: {'text': _textController.text});
      _textController.clear();
      _loadInvestigations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Investigation added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add investigation: $e')),
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
    title: Text(_selectedLanguage == 'en' ? 'Investigations' : 'ஆய்வுகள்', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
      : _investigations.isEmpty
      ? Center(child: Text(_selectedLanguage == 'en' ? 'No investigations found.' : 'ஆய்வுகள் இல்லை.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _investigations.length,
                      itemBuilder: (context, index) {
                        final c = _investigations[index];
                        final expectedFields = <String, String>{
                          'Hb': 'Hb',
                          'Total_leukocyte_count': 'Total leukocyte count',
                          'Differential_count': 'Differential count',
                          'Platelet_count': 'Platelet count',
                          'ESR': 'ESR',
                          'CRP': 'CRP',
                          'Lft_total_bilirubin': 'LFT total bilirubin',
                          'Lft_direct_bilirubin': 'LFT direct bilirubin',
                          'AST': 'AST',
                          'ALT': 'ALT',
                          'Albumin': 'Albumin',
                          'Total_protein': 'Total protein',
                          'GGT': 'GGT',
                          'Urea': 'Urea',
                          'creatinine': 'Creatinine',
                          'uric_acid': 'Uric acid',
                          'Urine_routine': 'Urine routine',
                          'Urine_PCR': 'Urine PCR',
                          'RA_factor': 'RA factor',
                          'ANTI_CCP': 'ANTI CCP',
                        };

                        final hasAny = expectedFields.keys.any((k) {
                          final v1 = c[k];
                          final v2 = c[k.toLowerCase()];
                          return (v1 != null && v1.toString().trim().isNotEmpty) || (v2 != null && v2.toString().trim().isNotEmpty);
                        });
                        final created = c['createdAt'] ?? c['created_at'];
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
                                    const Icon(Icons.science, color: Colors.deepPurple),
                                    const SizedBox(width: 8),
                                    Text(_selectedLanguage == 'en' ? 'Investigation' : 'ஆய்வு', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.deepPurple)),
                                    const Spacer(),
                                    if (created != null)
                                      Text(
                                        created.toString().split('T').first,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (!hasAny)
                                  const Text('No data', style: TextStyle(color: Colors.grey))
                                else
                                  ...expectedFields.entries.map<Widget>((entry) {
                                    final key = entry.key;
                                    final label = entry.value;
                                    final raw = c[key] ?? c[key.toLowerCase()];
                                    final value = (raw != null && raw.toString().trim().isNotEmpty) ? raw.toString() : 'No data';
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.circle, size: 8, color: Colors.deepPurple),
                                          const SizedBox(width: 6),
                                          Expanded(child: Text('$label: $value', style: const TextStyle(fontSize: 15))),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 