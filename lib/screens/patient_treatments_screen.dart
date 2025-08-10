import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientTreatmentsScreen extends StatefulWidget {
  final int? patientUid;
  const PatientTreatmentsScreen({super.key, this.patientUid});

  @override
  State<PatientTreatmentsScreen> createState() => _PatientTreatmentsScreenState();
}

class _PatientTreatmentsScreenState extends State<PatientTreatmentsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _treatments = [];
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
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() { _isLoading = true; });
    try {
      final treatments = await _apiService.getPatientTreatments(uid: _uid);
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
      await _apiService.addPatientTreatment(uid: _uid, data: {'text': _textController.text});
      _textController.clear();
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments'),
      ),
      floatingActionButton: _userRole == 'doctor'
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Treatment'),
                    content: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(labelText: 'Treatment'),
                        validator: (value) => value == null || value.isEmpty ? 'Enter a value' : null,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addTreatment,
                          child: const Text('Add Treatment'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Add Treatment',
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _treatments.isEmpty
                  ? const Center(child: Text('No treatments found.'))
                  : ListView.builder(
                      itemCount: _treatments.length,
                      itemBuilder: (context, index) {
                        final c = _treatments[index];
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