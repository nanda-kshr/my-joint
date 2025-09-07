import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PatientMedicationsScreen extends StatefulWidget {
  final String? patientUid;
  const PatientMedicationsScreen({super.key, this.patientUid});

  @override
  State<PatientMedicationsScreen> createState() => _PatientMedicationsScreenState();
}

class _PatientMedicationsScreenState extends State<PatientMedicationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _medications = [];
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
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() { _isLoading = true; });
    try {
      final medications = await _apiService.getPatientMedications(uid: _uid);
      // Normalize each record's medications field: backend may return a JSON string
      // or a List. Convert strings into List<Map<String, dynamic>>.
      final parsed = medications.map<Map<String, dynamic>>((c) {
        final medsField = c['medications'];
        List<dynamic> medsList;
        try {
          if (medsField == null) {
            medsList = [];
          } else if (medsField is List) {
            medsList = medsField;
          } else if (medsField is String) {
            if (medsField.trim().isEmpty) {
              medsList = [];
            } else {
              final decoded = jsonDecode(medsField);
              medsList = decoded is List ? decoded : [];
            }
          } else {
            medsList = [];
          }
        } catch (e) {
          print('Error parsing medications JSON: $e');
          medsList = [];
        }
        return {
          ...Map<String, dynamic>.from(c),
          'medications': medsList,
        };
      }).toList();
      setState(() {
        _medications = List<Map<String, dynamic>>.from(parsed);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addMedication() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _apiService.addPatientMedication(uid: _uid, medications: _textController.text);
      _textController.clear();
      _loadMedications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add medication: $e')),
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
        title: const Text('Medications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _medications.isEmpty
                  ? Center(child: Text(_selectedLanguage == 'en' ? 'No medications found.' : 'மருந்துகள் இல்லை.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final c = _medications[index];
                        final meds = c['medications'] is List ? c['medications'] : [];
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
                                    const Icon(Icons.medication, color: Colors.blueAccent),
                                    const SizedBox(width: 8),
                                    Text(_selectedLanguage == 'en' ? 'Prescription' : 'மருந்து பரிந்துரை', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.blueAccent)),
                                    const Spacer(),
                                    if (c['createdAt'] != null)
                                      Text(
                                        c['createdAt'].toString().split('T').first,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (meds.isNotEmpty)
                                  ...meds.map<Widget>((m) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.circle, size: 8, color: Colors.blueAccent),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                '${m['name'] ?? ''} (${m['dose'] ?? ''}${m['period'] != null ? ', ' + m['period'] : ''})',
                                                style: const TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                if (meds.isEmpty)
                                  Text(_selectedLanguage == 'en' ? 'No medications' : 'மருந்துகள் இல்லை', style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 