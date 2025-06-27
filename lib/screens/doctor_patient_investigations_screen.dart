import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientInvestigationsScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientInvestigationsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientInvestigationsScreen> createState() => _DoctorPatientInvestigationsScreenState();
}

class _DoctorPatientInvestigationsScreenState extends State<DoctorPatientInvestigationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _investigations = [];
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _resultsController = TextEditingController();
  final _fileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadInvestigations();
  }

  Future<void> _loadInvestigations() async {
    try {
      final investigations = await _apiService.getDoctorPatientInvestigations(widget.patientId);
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
      final investigationData = {
        'type': _typeController.text,
        'date': _dateController.text,
        'description': _descriptionController.text,
        'results': _resultsController.text,
        'file': _fileController.text,
      };

      await _apiService.addDoctorPatientInvestigation(widget.patientId, investigationData);
      _clearForm();
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

  Future<void> _updateInvestigationStatus(String investigationId, String status) async {
    try {
      await _apiService.updateDoctorPatientInvestigation(widget.patientId, investigationId, {'status': status});
      _loadInvestigations();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Investigation status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update investigation status: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _typeController.clear();
    _dateController.clear();
    _descriptionController.clear();
    _resultsController.clear();
    _fileController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Investigations'),
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
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter date';
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
                              controller: _resultsController,
                              decoration: const InputDecoration(
                                labelText: 'Results',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter results';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _fileController,
                              decoration: const InputDecoration(
                                labelText: 'File URL',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter file URL';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addInvestigation,
                              child: const Text('Add Investigation'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Investigation List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _investigations.length,
                        itemBuilder: (context, index) {
                          final investigation = _investigations[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(investigation['type']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${investigation['date']}'),
                                  Text('Description: ${investigation['description']}'),
                                  Text('Results: ${investigation['results']}'),
                                  Text('Status: ${investigation['status']}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {
                                      // TODO: Implement file download
                                    },
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (status) {
                                      _updateInvestigationStatus(investigation['id'], status);
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'pending',
                                        child: Text('Pending'),
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
    _dateController.dispose();
    _descriptionController.dispose();
    _resultsController.dispose();
    _fileController.dispose();
    super.dispose();
  }
} 