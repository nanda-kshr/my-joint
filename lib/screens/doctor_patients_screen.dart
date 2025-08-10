import 'package:flutter/material.dart';
import 'package:my_joints/screens/doctor_patient_detail_screen.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientsScreen extends StatefulWidget {
  const DoctorPatientsScreen({super.key});

  @override
  State<DoctorPatientsScreen> createState() => _DoctorPatientsScreenState();
}

class _DoctorPatientsScreenState extends State<DoctorPatientsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _patients = [];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patients = await _apiService.getPatients();
      setState(() {
        _patients = List<Map<String, dynamic>>.from(patients);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showLinkPatientDialog() async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Link New Patient'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(hintText: "Patient's Email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final did = int.tryParse(prefs.getString('user_id') ?? '');
                    if (did != null) {
                      await _apiService.linkDoctorPatient(
                        patientEmail: emailController.text,
                        did: did,
                      );
                      Navigator.pop(context);
                      _loadPatients(); // Refresh the list
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not find doctor ID.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to link patient: $e')),
                    );
                  }
                }
              },
              child: const Text('Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('My Patients', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _patients.isEmpty
                  ? const Center(child: Text('No patients found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _patients.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(patient['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w500)),
                            subtitle: Text(patient['email'] ?? '', style: const TextStyle(color: Colors.black54)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blueAccent),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorPatientDetailScreen(patient: patient),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showLinkPatientDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
        tooltip: 'Link New Patient',
      ),
    );
  }
}