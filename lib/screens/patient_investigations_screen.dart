import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientInvestigationsScreen extends StatefulWidget {
  const PatientInvestigationsScreen({super.key});

  @override
  State<PatientInvestigationsScreen> createState() => _PatientInvestigationsScreenState();
}

class _PatientInvestigationsScreenState extends State<PatientInvestigationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _investigations = [];

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
      final investigations = await _apiService.getPatientInvestigations();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Investigations'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _investigations.length,
                  itemBuilder: (context, index) {
                    final investigation = _investigations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(investigation['type']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: ${investigation['date']}'),
                            Text('Results: ${investigation['results']}'),
                            Text('Performed By: ${investigation['performedBy']}'),
                            if (investigation['attachments'] != null &&
                                (investigation['attachments'] as List).isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Attachments:'),
                              ...List<Widget>.from(
                                (investigation['attachments'] as List).map(
                                  (attachment) => Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Text('• $attachment'),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 