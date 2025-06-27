import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientMedicationsScreen extends StatefulWidget {
  const PatientMedicationsScreen({super.key});

  @override
  State<PatientMedicationsScreen> createState() => _PatientMedicationsScreenState();
}

class _PatientMedicationsScreenState extends State<PatientMedicationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _medications = [];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final medications = await _apiService.getPatientMedications();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _medications.length,
                  itemBuilder: (context, index) {
                    final medication = _medications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(medication['name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dosage: ${medication['dosage']}'),
                            Text('Frequency: ${medication['frequency']}'),
                            Text('Start Date: ${medication['startDate']}'),
                            if (medication['endDate'] != null)
                              Text('End Date: ${medication['endDate']}'),
                            Text('Prescribed By: ${medication['prescribedBy']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 