import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'doctor_patients_screen.dart';
import 'doctor_patient_detail_screen.dart';
import 'doctor_message_screen.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  late ApiService _apiService;
  List<dynamic> _patients = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userData;
  List<dynamic> _notifications = [];
  String _selectedLanguage = 'en';

  @override
  void initState() {
  super.initState();
  _initializeApiService();
  _loadLanguage();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    await _loadData();
    await _fetchNotifications();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }


  Future<void> _fetchNotifications() async {
    try {
      final userId = await _apiService.getUserId();
      if (userId == null) return;
      final response = await _apiService.getAuthenticated('${ApiService.baseUrl}/doctor/notifications?doctor_id=$userId');
      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty ? Map<String, dynamic>.from(jsonDecode(response.body)) : {};
        setState(() {
          _notifications = data['notifications'] ?? [];
        });
      }
    } catch (e) {
      // Optionally handle error
    }
  }

  Future<void> _loadData() async {
    try {
      final userData = await _apiService.getDoctorProfile();
      final userId = await _apiService.getUserId();
      final patients = await _apiService.getDoctorPatients(int.parse(userId ?? '0'));
      setState(() {
        _userData = userData;
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationStatus(int notificationId, String status) async {
    try {
      final response = await _apiService.updateNotificationStatus(notificationId, status);
      if (response.statusCode == 200) {
        await _fetchNotifications();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update notification status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _apiService.clearStoredData();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userData?['name'] ?? (_selectedLanguage == 'en' ? 'Doctor Dashboard' : 'மருத்துவர் டாஷ்போர்டு')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: _selectedLanguage == 'en' ? 'Settings' : 'அமைப்புகள்',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: _selectedLanguage == 'en' ? 'Logout' : 'வெளியேறு',
          ),
        ],
      ),
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
                        onPressed: _loadData,
                        child: Text(_selectedLanguage == 'en' ? 'Retry' : 'மீண்டும் முயற்சி'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(_userData?['name'] ?? (_selectedLanguage == 'en' ? 'Doctor' : 'மருத்துவர்')),
                        subtitle: Text(_userData?['email'] ?? ''),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.people, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          Text(
                            _selectedLanguage == 'en'
                                ? 'My Patients (${_patients.length})'
                                : 'என் நோயாளிகள் (${_patients.length})',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _patients.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    _selectedLanguage == 'en'
                                        ? 'No patients assigned yet.'
                                        : 'நோயாளிகள் ஏதும் வழங்கப்படவில்லை.',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _patients.length,
                              itemBuilder: (context, index) {
                                final patient = _patients[index];
                                // Find notification for this patient
                                final notification = _notifications.firstWhere(
                                  (n) => n['patient_id'] == patient['uid'],
                                  orElse: () => null,
                                );
                                Widget? statusWidget;
                                if (notification != null) {
                                  if (notification['status'] == 'pending') {
                                    statusWidget = Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.message, color: Colors.blue),
                                          tooltip: 'View Message',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => DoctorMessageScreen(
                                                complaint: notification['message'] ?? 'No complaint provided.',
                                                onApprove: () {
                                                  Navigator.of(ctx).pop();
                                                  _updateNotificationStatus(notification['id'], 'accepted');
                                                },
                                                onReject: () {
                                                  Navigator.of(ctx).pop();
                                                  _updateNotificationStatus(notification['id'], 'rejected');
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  } else if (notification['status'] == 'accepted') {
                                    statusWidget = const Icon(Icons.check_circle, color: Colors.green);
                                  } else if (notification['status'] == 'rejected') {
                                    statusWidget = const Icon(Icons.cancel, color: Colors.red);
                                  }
                                }
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    title: Text(patient['name'] ?? 'Unknown'),
                                    subtitle: Text(patient['email'] ?? ''),
                                    trailing: statusWidget ?? const Icon(Icons.arrow_forward_ios),
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
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DoctorPatientsScreen(),
            ),
          );
        },
        tooltip: _selectedLanguage == 'en' ? 'Manage Patients' : 'நோயாளிகளை நிர்வகிக்கவும்',
        child: const Icon(Icons.add),
      ),
    );
  }
} 