import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientTreatmentsScreen extends StatefulWidget {
  const PatientTreatmentsScreen({super.key});

  @override
  State<PatientTreatmentsScreen> createState() => _PatientTreatmentsScreenState();
}

class _PatientTreatmentsScreenState extends State<PatientTreatmentsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _treatments = [];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    try {
      final treatments = await _apiService.getPatientTreatments();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Treatments'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _treatments.length,
                  itemBuilder: (context, index) {
                    final treatment = _treatments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(treatment['type']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Date: ${treatment['startDate']}'),
                            if (treatment['endDate'] != null)
                              Text('End Date: ${treatment['endDate']}'),
                            Text('Frequency: ${treatment['frequency']}'),
                            Text('Provider: ${treatment['provider']}'),
                            Text('Status: ${treatment['status']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 