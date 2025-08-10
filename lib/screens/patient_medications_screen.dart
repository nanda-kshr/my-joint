import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientMedicationsScreen extends StatefulWidget {
  final int? patientUid;
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
  int? _uid;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _userRole = await _apiService.getUserType();
    _uid = widget.patientUid ?? int.tryParse(await _apiService.getUserId() ?? '');
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() { _isLoading = true; });
    try {
      final medications = await _apiService.getPatientMedications(uid: _uid);
      setState(() {
        _medications = List<Map<String, dynamic>>.from(medications);
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
        title: const Text('Medications'),
      ),
      floatingActionButton: _userRole == 'doctor'
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Medication'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _textController,
                            decoration: const InputDecoration(labelText: 'Medication'),
                            validator: (value) => value == null || value.isEmpty ? 'Enter a value' : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _addMedication,
                              child: const Text('Add Medication'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Add Medication',
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _medications.isEmpty
                  ? const Center(child: Text('No medications found.'))
                  : ListView.builder(
                      itemCount: _medications.length,
                      itemBuilder: (context, index) {
                        final c = _medications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(c['text'] ?? ''),
                            subtitle: Text('Added: ${c['createdAt'] ?? ''}'),
                          ),
                        );
                      },
                    ),
    );
  }
} 