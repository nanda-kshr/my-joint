import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientPrescriptionsScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientPrescriptionsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientPrescriptionsScreen> createState() => _DoctorPatientPrescriptionsScreenState();
}

class _DoctorPatientPrescriptionsScreenState extends State<DoctorPatientPrescriptionsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _prescriptions = [];
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _durationController = TextEditingController();
  final _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadPrescriptions();
  }

  Future<void> _loadPrescriptions() async {
    try {
      final prescriptions = await _apiService.getDoctorPatientPrescriptions(widget.patientId);
      setState(() {
        _prescriptions = List<Map<String, dynamic>>.from(prescriptions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addPrescription() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final prescriptionData = {
        'medication': _medicationController.text,
        'dosage': _dosageController.text,
        'frequency': _frequencyController.text,
        'duration': _durationController.text,
        'instructions': _instructionsController.text,
      };

      await _apiService.addDoctorPatientPrescription(widget.patientId, prescriptionData);
      _clearForm();
      _loadPrescriptions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add prescription: $e')),
        );
      }
    }
  }

  Future<void> _updatePrescriptionStatus(String prescriptionId, String status) async {
    try {
      await _apiService.updateDoctorPatientPrescription(widget.patientId, prescriptionId, {'status': status});
      _loadPrescriptions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update prescription status: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _medicationController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _durationController.clear();
    _instructionsController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Prescriptions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _medicationController,
                              decoration: const InputDecoration(
                                labelText: 'Medication',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter medication';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dosageController,
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
                              controller: _frequencyController,
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
                            TextFormField(
                              controller: _durationController,
                              decoration: const InputDecoration(
                                labelText: 'Duration',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter duration';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _instructionsController,
                              decoration: const InputDecoration(
                                labelText: 'Instructions',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter instructions';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addPrescription,
                              child: const Text('Add Prescription'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Prescription List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _prescriptions.length,
                        itemBuilder: (context, index) {
                          final prescription = _prescriptions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(prescription['medication']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dosage: ${prescription['dosage']}'),
                                  Text('Frequency: ${prescription['frequency']}'),
                                  Text('Duration: ${prescription['duration']}'),
                                  Text('Instructions: ${prescription['instructions']}'),
                                  Text('Status: ${prescription['status']}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (status) {
                                  _updatePrescriptionStatus(prescription['id'], status);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'active',
                                    child: Text('Active'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'completed',
                                    child: Text('Completed'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'cancelled',
                                    child: Text('Cancelled'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _durationController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
} 