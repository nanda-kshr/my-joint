import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientComorbiditiesScreen extends StatefulWidget {
  final int? patientUid;
  const PatientComorbiditiesScreen({super.key, this.patientUid});

  @override
  State<PatientComorbiditiesScreen> createState() => _PatientComorbiditiesScreenState();
}

class _PatientComorbiditiesScreenState extends State<PatientComorbiditiesScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _comorbidities = [];
  int? _uid;

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _uid = widget.patientUid ?? int.tryParse(await _apiService.getUserId() ?? '');
    _loadComorbidities();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comorbidities', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _comorbidities.isEmpty
                  ? const Center(child: Text('No comorbidities found.'))
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
                                    Text('Comorbidity', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.orange)),
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