import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientComplaintsScreen extends StatefulWidget {
  final int? patientUid;
  const PatientComplaintsScreen({super.key, this.patientUid});

  @override
  State<PatientComplaintsScreen> createState() => _PatientComplaintsScreenState();
}

class _PatientComplaintsScreenState extends State<PatientComplaintsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _complaints = [];
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
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    setState(() { _isLoading = true; });
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
        title: const Text('Complaints', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.redAccent),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _complaints.isEmpty
                  ? const Center(child: Text('No complaints found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _complaints.length,
                      itemBuilder: (context, index) {
                        final c = _complaints[index];
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
                                    const Icon(Icons.sick, color: Colors.redAccent),
                                    const SizedBox(width: 8),
                                    Text('Complaint', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.redAccent)),
                                    const Spacer(),
                                    if (c['createdAt'] != null)
                                      Text(
                                        c['createdAt'].toString().split('T').first,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(c['complaint'] ?? c['text'] ?? '', style: const TextStyle(fontSize: 15)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
  }
