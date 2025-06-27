import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientDetailsScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientDetailsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientDetailsScreen> createState() => _DoctorPatientDetailsScreenState();
}

class _DoctorPatientDetailsScreenState extends State<DoctorPatientDetailsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _patientDetails;
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _prescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadPatientDetails();
  }

  Future<void> _loadPatientDetails() async {
    try {
      final details = await _apiService.getDoctorPatientDetails(widget.patientId);
      setState(() {
        _patientDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _updatePatientDetails() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updateData = {
        'notes': _notesController.text,
        'diagnosis': _diagnosisController.text,
        'treatment': _treatmentController.text,
        'prescription': _prescriptionController.text,
      };

      await _apiService.updateDoctorPatientDetails(widget.patientId, updateData);
      _loadPatientDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient details updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update patient details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _patientDetails == null
                  ? const Center(child: Text('No patient details found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _patientDetails!['name'],
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Age: ${_patientDetails!['age']}'),
                                  Text('Gender: ${_patientDetails!['gender']}'),
                                  Text('Email: ${_patientDetails!['email']}'),
                                  Text('Phone: ${_patientDetails!['phone']}'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                TextFormField(
                                  controller: _notesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Notes',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  initialValue: _patientDetails!['notes'],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter notes';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _diagnosisController,
                                  decoration: const InputDecoration(
                                    labelText: 'Diagnosis',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  initialValue: _patientDetails!['diagnosis'],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter diagnosis';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _treatmentController,
                                  decoration: const InputDecoration(
                                    labelText: 'Treatment',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  initialValue: _patientDetails!['treatment'],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter treatment';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _prescriptionController,
                                  decoration: const InputDecoration(
                                    labelText: 'Prescription',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                  initialValue: _patientDetails!['prescription'],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter prescription';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _updatePatientDetails,
                                  child: const Text('Update Details'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Medical History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(_patientDetails!['medicalHistory']),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Recent Visits',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (_patientDetails!['recentVisits'] as List).length,
                            itemBuilder: (context, index) {
                              final visit = _patientDetails!['recentVisits'][index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(visit['date']),
                                  subtitle: Text(visit['reason']),
                                  trailing: Text(visit['status']),
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
    _notesController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _prescriptionController.dispose();
    super.dispose();
  }
} 