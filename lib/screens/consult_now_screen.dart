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
  int? _patientId;

  @override
  void initState() {
    super.initState();
    _initApi();
  }

  Future<void> _initApi() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _patientId = int.tryParse(await _apiService.getUserId() ?? '');
    await _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    try {
      if (_patientId == null) throw Exception('No patient ID');
      final response = await _apiService.getAuthenticated(
        '${ApiService.baseUrl}/patient/doctors?patient_id=$_patientId',
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

  Future<void> _consultDoctor(int doctorId) async {
    if (_patientId == null) return;
    try {
      await requestConsultation(_apiService, patientId: _patientId!, doctorId: doctorId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consult Now')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _doctors.isEmpty
              ? const Center(child: Text('No doctors found.'))
              : ListView.builder(
                  itemCount: _doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = _doctors[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.person, color: Colors.blue),
                        title: Text(doctor['name'] ?? 'Doctor'),
                        subtitle: Text(doctor['specialization'] ?? ''),
                        trailing: ElevatedButton(
                          onPressed: () => _consultDoctor(doctor['did'] ?? doctor['id']),
                          child: const Text('Consult Now'),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
