import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientInvestigationsScreen extends StatefulWidget {
  final int? patientUid;
  const PatientInvestigationsScreen({super.key, this.patientUid});

  @override
  State<PatientInvestigationsScreen> createState() => _PatientInvestigationsScreenState();
}

class _PatientInvestigationsScreenState extends State<PatientInvestigationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _investigations = [];
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
    _loadInvestigations();
  }

  Future<void> _loadInvestigations() async {
    setState(() { _isLoading = true; });
    try {
      final investigations = await _apiService.getPatientInvestigations(uid: _uid);
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
      await _apiService.addPatientInvestigation(uid: _uid, data: {'text': _textController.text});
      _textController.clear();
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

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investigations'),
      ),
      floatingActionButton: _userRole == 'doctor'
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Investigation'),
                    content: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(labelText: 'Investigation'),
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
                          onPressed: _addInvestigation,
                          child: const Text('Add Investigation'),
                        ),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Add Investigation',
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _investigations.isEmpty
                  ? const Center(child: Text('No investigations found.'))
                  : ListView.builder(
                      itemCount: _investigations.length,
                      itemBuilder: (context, index) {
                        final c = _investigations[index];
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