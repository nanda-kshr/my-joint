import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientRecordsScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientRecordsScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientRecordsScreen> createState() => _DoctorPatientRecordsScreenState();
}

class _DoctorPatientRecordsScreenState extends State<DoctorPatientRecordsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _patientRecords;
  final _formKey = GlobalKey<FormState>();
  final _recordTypeController = TextEditingController();
  final _recordDateController = TextEditingController();
  final _recordDescriptionController = TextEditingController();
  final _recordFileController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadPatientRecords();
  }

  Future<void> _loadPatientRecords() async {
    try {
      final records = await _apiService.getDoctorPatientRecords(widget.patientId);
      setState(() {
        _patientRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addPatientRecord() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final recordData = {
        'type': _recordTypeController.text,
        'date': _recordDateController.text,
        'description': _recordDescriptionController.text,
        'file': _recordFileController.text,
      };

      await _apiService.addDoctorPatientRecord(widget.patientId, recordData);
      _clearForm();
      _loadPatientRecords();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add record: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _recordTypeController.clear();
    _recordDateController.clear();
    _recordDescriptionController.clear();
    _recordFileController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Records'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _patientRecords == null
                  ? const Center(child: Text('No patient records found'))
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
                                  controller: _recordTypeController,
                                  decoration: const InputDecoration(
                                    labelText: 'Record Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter record type';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _recordDateController,
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
                                  controller: _recordDescriptionController,
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
                                  controller: _recordFileController,
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
                                  onPressed: _addPatientRecord,
                                  child: const Text('Add Record'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Medical Records',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: (_patientRecords!['records'] as List).length,
                            itemBuilder: (context, index) {
                              final record = _patientRecords!['records'][index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(record['type']),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date: ${record['date']}'),
                                      Text(record['description']),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {
                                      // TODO: Implement file download
                                    },
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
    _recordTypeController.dispose();
    _recordDateController.dispose();
    _recordDescriptionController.dispose();
    _recordFileController.dispose();
    super.dispose();
  }
} 