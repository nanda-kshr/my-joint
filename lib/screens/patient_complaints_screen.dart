import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientComplaintsScreen extends StatefulWidget {
  const PatientComplaintsScreen({super.key});

  @override
  State<PatientComplaintsScreen> createState() => _PatientComplaintsScreenState();
}

class _PatientComplaintsScreenState extends State<PatientComplaintsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _complaints = [];
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  String _selectedSeverity = 'medium';

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      final complaints = await _apiService.getPatientComplaints();
      setState(() {
        _complaints = List<Map<String, dynamic>>.from(complaints);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addComplaint() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final complaintData = {
        'description': _descriptionController.text,
        'severity': _selectedSeverity,
        'location': _locationController.text,
        'duration': _durationController.text,
      };

      await _apiService.addPatientComplaint(complaintData);
      _descriptionController.clear();
      _locationController.clear();
      _durationController.clear();
      _loadComplaints();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complaint added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add complaint: $e')),
        );
      }
    }
  }

  Future<void> _updateComplaintStatus(String complaintId, String status) async {
    try {
      await _apiService.updatePatientComplaint(complaintId, status);
      _loadComplaints();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a description';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the location';
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
                                  return 'Please enter the duration';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedSeverity,
                              decoration: const InputDecoration(
                                labelText: 'Severity',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'low', child: Text('Low')),
                                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                                DropdownMenuItem(value: 'high', child: Text('High')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSeverity = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addComplaint,
                              child: const Text('Add Complaint'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _complaints.length,
                        itemBuilder: (context, index) {
                          final complaint = _complaints[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(complaint['description']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Location: ${complaint['location']}'),
                                  Text('Duration: ${complaint['duration']}'),
                                  Text('Severity: ${complaint['severity']}'),
                                  Text('Status: ${complaint['status']}'),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (status) =>
                                    _updateComplaintStatus(complaint['id'], status),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'active',
                                    child: Text('Mark as Active'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'resolved',
                                    child: Text('Mark as Resolved'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    super.dispose();
  }
} 