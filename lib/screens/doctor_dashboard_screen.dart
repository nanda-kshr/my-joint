import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userData = await _apiService.getDoctorProfile();
      final patients = await _apiService.getPatients();
      setState(() {
        _userData = userData;
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
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
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_userData?['name'] ?? 'Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(_userData?['name'] ?? 'Doctor'),
                        subtitle: Text(_userData?['email'] ?? ''),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _patients.length,
                        itemBuilder: (context, index) {
                          final patient = _patients[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(patient['name'] ?? 'Unknown'),
                              subtitle: Text(patient['email'] ?? ''),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () {
                                // TODO: Navigate to patient details
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
          // TODO: Add new patient
        },
        child: const Icon(Icons.add),
      ),
    );
  }
} 