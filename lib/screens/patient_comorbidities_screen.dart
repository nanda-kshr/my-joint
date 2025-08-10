import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientComorbiditiesScreen extends StatefulWidget {
  final int? patientUid;
  const PatientComorbiditiesScreen({super.key, this.patientUid});

  @override
  State<PatientComorbiditiesScreen> createState() => _PatientComorbiditiesScreenState();
}

class _PatientComorbiditiesScreenState extends State<PatientComorbiditiesScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _comorbidities = [];
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
    _loadComorbidities();
  }

  Future<void> _loadComorbidities() async {
    setState(() { _isLoading = true; });
    try {
      final comorbidities = await _apiService.getPatientComorbidities(uid: _uid);
      setState(() {
        _comorbidities = List<Map<String, dynamic>>.from(comorbidities);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _addComorbidity() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _apiService.addPatientComorbidity(uid: _uid, text: _textController.text);
      _textController.clear();
      Navigator.pop(context); // Close dialog
      _loadComorbidities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comorbidity added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comorbidity: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteComorbidity(int id) async {
    try {
      await _apiService.deletePatientComorbidity(id: id);
      _loadComorbidities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comorbidity deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete comorbidity: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
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
        title: const Text('Comorbidities'),
      ),
      floatingActionButton: _userRole == 'doctor'
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Comorbidity'),
                    content: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          labelText: 'Comorbidity',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                        validator: (value) => value == null || value.isEmpty ? 'Enter a comorbidity' : null,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: _addComorbidity,
                        child: const Text('Add Comorbidity'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Add Comorbidity',
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadComorbidities,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _comorbidities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No comorbidities found.',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _comorbidities.length,
                      itemBuilder: (context, index) {
                        final comorbidity = _comorbidities[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(comorbidity['text'] ?? ''),
                            subtitle: Text(
                              'Added: ${comorbidity['createdAt'] != null ? DateTime.parse(comorbidity['createdAt']).toString().split('.')[0] : 'Unknown'}',
                            ),
                            trailing: _userRole == 'doctor'
                                ? IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Comorbidity'),
                                          content: const Text('Are you sure you want to delete this comorbidity?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteComorbidity(comorbidity['id']);
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
    );
  }
} 