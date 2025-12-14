import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ConsultNowScreen extends StatefulWidget {
  const ConsultNowScreen({Key? key}) : super(key: key);

  @override
  State<ConsultNowScreen> createState() => _ConsultNowScreenState();
}

class _ConsultNowScreenState extends State<ConsultNowScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  List<dynamic> _doctors = [];
  String? _patientId;

  @override
  void initState() {
    super.initState();
    _initApi();
  }

  Future<void> _initApi() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _patientId = await _apiService.getUserId() ?? '';
    await _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    try {
      if (_patientId == null) throw Exception('No patient ID');
      final response = await _apiService.getAuthenticated(
        '${ApiService.baseUrl}/patient/doctors.php?patient_id=$_patientId',
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _doctors = data['doctors'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch doctors');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch doctors: $e')),
      );
    }
  }

  Future<void> _consultDoctor(String doctorId) async {
    if (_patientId == null) return;
    try {
      await requestConsultation(
        _apiService,
        patientId: _patientId!,
        doctorId: doctorId,
        message: _complaint.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }

  String? _selectedDoctorId;
  String _complaint = '';
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consult Now')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(child: Text('No doctors found.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _doctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _doctors[index];
                          final doctorId = doctor['did'] ?? doctor['id'];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.person, color: Colors.blue),
                              title: Text(doctor['name'] ?? 'Doctor'),
                              subtitle: Text(doctor['specialization'] ?? ''),
                              trailing: Radio<String>(
                                value: doctorId,
                                groupValue: _selectedDoctorId,
                                onChanged: (val) {
                                  setState(() {
                                    _selectedDoctorId = val;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_selectedDoctorId != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Describe your complaint',
                            border: OutlineInputBorder(),
                          ),
                          minLines: 2,
                          maxLines: 4,
                          onChanged: (val) => setState(() => _complaint = val),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _sending || _complaint.trim().isEmpty
                                ? null
                                : () async {
                                    setState(() => _sending = true);
                                    await _consultDoctor(_selectedDoctorId!);
                                    setState(() => _sending = false);
                                  },
                            child: _sending
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Send'),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}
