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
        _error = e.toString().replaceAll('Exception: ', '');
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(_userData?['name'] ?? 'Patient Dashboard', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
            tooltip: 'Logout',
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
                        onPressed: _loadUserData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(_userData?['name'] ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(_userData?['email'] ?? '', style: const TextStyle(color: Colors.black54)),
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
                            'Complaints',
                            Icons.note_add,
                            Colors.blue,
                            () => _showDataDialog(
                              context,
                              title: 'Complaints',
                              fetcher: () => _apiService.getPatientComplaints(),
                              itemBuilder: (item) => ListTile(
                                title: Text(item['complaint'] ?? item['text'] ?? ''),
                                subtitle: item['createdAt'] != null
                                    ? Text('Added: ' + (item['createdAt'] ?? ''))
                                    : null,
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            'Comorbidities',
                            Icons.medical_services,
                            Colors.orange,
                            () => _showDataDialog(
                              context,
                              title: 'Comorbidities',
                              fetcher: () => _apiService.getPatientComorbidities(),
                              itemBuilder: (item) => ListTile(
                                title: Text(item['text'] ?? ''),
                                subtitle: item['createdAt'] != null
                                    ? Text('Added: ' + (item['createdAt'] ?? ''))
                                    : null,
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            'Disease Scores',
                            Icons.analytics,
                            Colors.green,
                            () => _showDataDialog(
                              context,
                              title: 'Disease Scores',
                              fetcher: () => _apiService.getPatientDiseaseScores(),
                              itemBuilder: (item) => ListTile(
                                title: Text('SDAI: ${item['SDAI'] ?? item['sdai'] ?? 'N/A'}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('DAS28-CRP: ${item['DAS_28_CRP'] ?? item['das_28_crp'] ?? 'N/A'}'),
                                    if (item['createdAt'] != null)
                                      Text('Date: ${item['createdAt']}'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            'Medications',
                            Icons.medication,
                            Colors.purple,
                            () => _showDataDialog(
                              context,
                              title: 'Medications',
                              fetcher: () => _apiService.getPatientMedications(),
                              itemBuilder: (item) {
                                final meds = item['medications'] is List
                                    ? item['medications']
                                    : [];
                                return ListTile(
                                  title: Text(meds.isNotEmpty
                                      ? meds.map((m) => m['name']).join(', ')
                                      : 'No medications'),
                                  subtitle: item['createdAt'] != null
                                      ? Text('Added: ' + (item['createdAt'] ?? ''))
                                      : null,
                                );
                              },
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            'Investigations',
                            Icons.science,
                            Colors.teal,
                            () => _showDataDialog(
                              context,
                              title: 'Investigations',
                              fetcher: () => _apiService.getPatientInvestigations(),
                              itemBuilder: (item) => ListTile(
                                title: Text('Hb: ${item['Hb'] ?? 'N/A'}'),
                                subtitle: item['createdAt'] != null
                                    ? Text('Date: ${item['createdAt']}')
                                    : null,
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            'Treatments',
                            Icons.healing,
                            Colors.indigo,
                            () => _showDataDialog(
                              context,
                              title: 'Treatments',
                              fetcher: () => _apiService.getPatientTreatments(),
                              itemBuilder: (item) => ListTile(
                                title: Text(item['treatment'] ?? ''),
                                subtitle: item['createdAt'] != null
                                    ? Text('Started: ' + (item['createdAt'] ?? ''))
                                    : null,
                              ),
                            ),
                          ),
                          _buildDashboardItem(
                            context,
                            'Referrals',
                            Icons.people,
                            Colors.red,
                            () => _showDataDialog(
                              context,
                              title: 'Referrals',
                              fetcher: () => _apiService.getPatientReferrals(),
                              itemBuilder: (item) => ListTile(
                                title: Text(item['text'] ?? ''),
                              ),
                            ),
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
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDataDialog(BuildContext context, {
    required String title,
    required Future<List<dynamic>> Function() fetcher,
    required Widget Function(dynamic item) itemBuilder,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: fetcher(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text(title),
                content: const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text(title),
                content: Text('Error: ${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            } else {
              final data = snapshot.data ?? [];
              return AlertDialog(
                title: Text(title),
                content: data.isEmpty
                    ? const Text('No data found.')
                    : SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) => itemBuilder(data[index]),
                        ),
                      ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
} 