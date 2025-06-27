import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientComorbiditiesScreen extends StatefulWidget {
  const PatientComorbiditiesScreen({super.key});

  @override
  State<PatientComorbiditiesScreen> createState() => _PatientComorbiditiesScreenState();
}

class _PatientComorbiditiesScreenState extends State<PatientComorbiditiesScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _comorbidities = [];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadComorbidities();
  }

  Future<void> _loadComorbidities() async {
    try {
      final comorbidities = await _apiService.getPatientComorbidities();
      setState(() {
        _comorbidities = List<Map<String, dynamic>>.from(comorbidities);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Co-morbidities'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _comorbidities.length,
                  itemBuilder: (context, index) {
                    final comorbidity = _comorbidities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(comorbidity['condition']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Diagnosed: ${comorbidity['diagnosedDate']}'),
                            Text('Severity: ${comorbidity['severity']}'),
                            const SizedBox(height: 4),
                            const Text('Medications:'),
                            ...List<Widget>.from(
                              (comorbidity['medications'] as List).map(
                                (med) => Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Text('• $med'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 