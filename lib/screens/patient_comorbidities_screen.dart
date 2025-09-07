import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientComorbiditiesScreen extends StatefulWidget {
  final String? patientUid;
  const PatientComorbiditiesScreen({super.key, this.patientUid});

  @override
  State<PatientComorbiditiesScreen> createState() => _PatientComorbiditiesScreenState();
}

class _PatientComorbiditiesScreenState extends State<PatientComorbiditiesScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _comorbidities = [];
  String? _uid;
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
    _uid = widget.patientUid ?? await _apiService.getUserId() ?? '';
    _loadComorbidities();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedLanguage == 'en' ? 'Comorbidities' : 'இணை நோய்கள்', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _comorbidities.isEmpty
                  ? Center(child: Text(_selectedLanguage == 'en' ? 'No comorbidities found.' : 'இணை நோய்கள் எதுவும் இல்லை.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _comorbidities.length,
                      itemBuilder: (context, index) {
                        final c = _comorbidities[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.medical_services, color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(_selectedLanguage == 'en' ? 'Comorbidity' : 'இணை நோய்', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.orange)),
                                    const Spacer(),
                                    if (c['createdAt'] != null)
                                      Text(
                                        c['createdAt'].toString().split('T').first,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(c['text'] ?? '', style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
  Future<void> _loadComorbidities() async {
    setState(() { _isLoading = true; });
    try {
      final comorbidities = await _apiService.getPatientComorbidities(uid: _uid);
      setState(() {
        _comorbidities = List<Map<String, dynamic>>.from(comorbidities);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }
}