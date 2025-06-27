import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> {
  late ApiService _apiService;
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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getPatientProfile();
      setState(() {
        _userData = userData;
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
        title: Text(_userData?['name'] ?? 'Patient Dashboard'),
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
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(_userData?['name'] ?? 'Patient'),
                          subtitle: Text(_userData?['email'] ?? ''),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildDashboardItem(
                            context,
                            'Joint Assessment',
                            Icons.medical_services,
                            () => Navigator.pushNamed(context, '/joint-assessment'),
                          ),
                          _buildDashboardItem(
                            context,
                            'Diet Plan',
                            Icons.restaurant,
                            () => Navigator.pushNamed(context, '/diet'),
                          ),
                          _buildDashboardItem(
                            context,
                            'Exercise',
                            Icons.fitness_center,
                            () => Navigator.pushNamed(context, '/exercise'),
                          ),
                          _buildDashboardItem(
                            context,
                            'Consult',
                            Icons.people,
                            () => Navigator.pushNamed(context, '/consult'),
                          ),
                          _buildDashboardItem(
                            context,
                            'Reports',
                            Icons.assessment,
                            () => Navigator.pushNamed(context, '/reports'),
                          ),
                          _buildDashboardItem(
                            context,
                            'Profile',
                            Icons.person,
                            () => Navigator.pushNamed(context, '/profile'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 