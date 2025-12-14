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
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _initializeApiService();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
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
  final lang = _selectedLanguage;
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
                    final did = prefs.getString(ApiService.userIdKey);
                    print('did: $prefs');
                    if (did != null) {
                      await _apiService.linkDoctorPatient(
                        patientEmail: emailController.text,
                        did: did,
                      );
                      Navigator.pop(context);
                      _loadPatients(); 
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lang == 'en' ? 'User cannot be added, ask admin' : 'பயனர் சேர்க்க முடியாது, நிர்வாசியை அணுகவும்')),
                      );
                    }
                    } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(lang == 'en' ? 'User cannot be added, ask admin' : 'பயனர் சேர்க்க முடியாது, நிர்வாசியை அணுகவும்')),
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
                            leading: Stack(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                if ((patient['consult_status'] ?? '') == 'pending' || patient['hasConsultRequest'] == true)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
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
        tooltip: 'Link New Patient',
        child: const Icon(Icons.add),
      ),
    );
  }
}