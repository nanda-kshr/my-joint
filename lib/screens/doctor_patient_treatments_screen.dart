import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientTreatmentsScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientTreatmentsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientTreatmentsScreen> createState() => _DoctorPatientTreatmentsScreenState();
}

class _DoctorPatientTreatmentsScreenState extends State<DoctorPatientTreatmentsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _treatments = [];
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _outcomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    try {
      final treatments = await _apiService.getDoctorPatientTreatments(widget.patientId);
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
      final treatmentData = {
        'type': _typeController.text,
        'startDate': _startDateController.text,
        'endDate': _endDateController.text,
        'description': _descriptionController.text,
        'outcome': _outcomeController.text,
      };

      await _apiService.addDoctorPatientTreatment(widget.patientId, treatmentData);
      _clearForm();
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

  Future<void> _updateTreatmentStatus(String treatmentId, String status) async {
    try {
      await _apiService.updateDoctorPatientTreatment(widget.patientId, treatmentId, {'status': status});
      _loadTreatments();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update treatment status: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _typeController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _descriptionController.clear();
    _outcomeController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Treatments'),
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
                              controller: _typeController,
                              decoration: const InputDecoration(
                                labelText: 'Treatment Type',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter treatment type';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _startDateController,
                              decoration: const InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter start date';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _endDateController,
                              decoration: const InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter end date';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _outcomeController,
                              decoration: const InputDecoration(
                                labelText: 'Outcome',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter outcome';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addTreatment,
                              child: const Text('Add Treatment'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Treatment List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _treatments.length,
                        itemBuilder: (context, index) {
                          final treatment = _treatments[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(treatment['type']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start Date: ${treatment['startDate']}'),
                                  Text('End Date: ${treatment['endDate']}'),
                                  Text('Description: ${treatment['description']}'),
                                  Text('Outcome: ${treatment['outcome']}'),
                                  Text('Status: ${treatment['status']}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (status) {
                                  _updateTreatmentStatus(treatment['id'], status);
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'ongoing',
                                    child: Text('Ongoing'),
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
    _typeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _outcomeController.dispose();
    super.dispose();
  }
} 