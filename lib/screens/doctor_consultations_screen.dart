import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorConsultationsScreen extends StatefulWidget {
  const DoctorConsultationsScreen({super.key});

  @override
  State<DoctorConsultationsScreen> createState() => _DoctorConsultationsScreenState();
}

class _DoctorConsultationsScreenState extends State<DoctorConsultationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _consultations = [];
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  final _followUpNotesController = TextEditingController();
  final _diseaseScoreController = TextEditingController();
  final _medicationNameController = TextEditingController();
  final _medicationDosageController = TextEditingController();
  final _medicationFrequencyController = TextEditingController();
  final _investigationTypeController = TextEditingController();
  final _investigationReasonController = TextEditingController();
  DateTime? _nextAppointment;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadConsultations();
  }

  Future<void> _loadConsultations() async {
    try {
      final consultations = await _apiService.getDoctorConsultations();
      setState(() {
        _consultations = List<Map<String, dynamic>>.from(consultations);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _selectNextAppointment() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextAppointment ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _nextAppointment) {
      setState(() {
        _nextAppointment = picked;
      });
    }
  }

  Future<void> _updateConsultation(String consultationId) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final consultationData = {
        'remarks': _remarksController.text,
        'diseaseScores': {
          'DAS28': double.parse(_diseaseScoreController.text),
        },
        'prescribedMedications': [
          {
            'name': _medicationNameController.text,
            'dosage': _medicationDosageController.text,
            'frequency': _medicationFrequencyController.text,
          }
        ],
        'recommendedInvestigations': [
          {
            'type': _investigationTypeController.text,
            'reason': _investigationReasonController.text,
          }
        ],
        'nextAppointment': _nextAppointment?.toIso8601String().split('T')[0],
        'followUpNotes': _followUpNotesController.text,
      };

      await _apiService.updateConsultation(consultationId, consultationData);
      _clearForm();
      _loadConsultations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Consultation updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update consultation: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _remarksController.clear();
    _followUpNotesController.clear();
    _diseaseScoreController.clear();
    _medicationNameController.clear();
    _medicationDosageController.clear();
    _medicationFrequencyController.clear();
    _investigationTypeController.clear();
    _investigationReasonController.clear();
    _nextAppointment = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _consultations.length,
                  itemBuilder: (context, index) {
                    final consultation = _consultations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ExpansionTile(
                        title: Text(consultation['patientName']),
                        subtitle: Text('Date: ${consultation['date']}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _remarksController,
                                    decoration: const InputDecoration(
                                      labelText: 'Remarks',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter remarks';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _diseaseScoreController,
                                    decoration: const InputDecoration(
                                      labelText: 'DAS28 Score',
                                      border: OutlineInputBorder(),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter DAS28 score';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Prescribed Medication',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _medicationNameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Medication Name',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter medication name';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _medicationDosageController,
                                    decoration: const InputDecoration(
                                      labelText: 'Dosage',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter dosage';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _medicationFrequencyController,
                                    decoration: const InputDecoration(
                                      labelText: 'Frequency',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter frequency';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Recommended Investigation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _investigationTypeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Investigation Type',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter investigation type';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _investigationReasonController,
                                    decoration: const InputDecoration(
                                      labelText: 'Reason',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter reason';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  InkWell(
                                    onTap: _selectNextAppointment,
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        labelText: 'Next Appointment',
                                        border: OutlineInputBorder(),
                                      ),
                                      child: Text(
                                        _nextAppointment == null
                                            ? 'Select Date'
                                            : '${_nextAppointment!.day}/${_nextAppointment!.month}/${_nextAppointment!.year}',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _followUpNotesController,
                                    decoration: const InputDecoration(
                                      labelText: 'Follow-up Notes',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter follow-up notes';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () => _updateConsultation(consultation['id']),
                                    child: const Text('Update Consultation'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _followUpNotesController.dispose();
    _diseaseScoreController.dispose();
    _medicationNameController.dispose();
    _medicationDosageController.dispose();
    _medicationFrequencyController.dispose();
    _investigationTypeController.dispose();
    _investigationReasonController.dispose();
    super.dispose();
  }
} 