import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class PatientComplaintsScreen extends StatefulWidget {
  final String? patientUid;
  const PatientComplaintsScreen({Key? key, this.patientUid}) : super(key: key);

  @override
  State<PatientComplaintsScreen> createState() => _PatientComplaintsScreenState();
}

class _PatientComplaintsScreenState extends State<PatientComplaintsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _complaints = [];
  String? _uid;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _initializeApiService();
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
    final storedUserId = await _apiService.getUserId();
    setState(() {
      _uid = widget.patientUid ?? storedUserId ?? '';
    });
    await _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() => _isLoading = true);
    try {
      final complaints = await _apiService.getPatientComplaints(uid: _uid);
      setState(() {
        _complaints = List<Map<String, dynamic>>.from(complaints);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == 'en' ? 'Complaints' : 'புகார்கள்',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.redAccent),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _complaints.isEmpty
                  ? Center(child: Text(_selectedLanguage == 'en' ? 'No complaints found.' : 'புகார்கள் எதுவும் இல்லை.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _complaints.length,
                      itemBuilder: (context, index) {
                        final c = _complaints[index];
                        final complaintText = c['complaint'] ?? '';
                        final description = c['description'] ?? '';
                        final dateText = c['created_at'] ?? '';
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(complaintText, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(description, style: const TextStyle(color: Colors.black54)),
                                const SizedBox(height: 8),
                                Text((
                                        _selectedLanguage == 'en' ? 'Date: ' : 'தேதி: '
                                      ) +
                                    dateText,
                                    style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
