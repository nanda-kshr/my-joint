import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientTreatmentsScreen extends StatefulWidget {
  final int? patientUid;
  const PatientTreatmentsScreen({super.key, this.patientUid});

  @override
  State<PatientTreatmentsScreen> createState() => _PatientTreatmentsScreenState();
}

class _PatientTreatmentsScreenState extends State<PatientTreatmentsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _treatments = [];
  String? _userRole;
  int? _uid;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _userRole = await _apiService.getUserType();
    _uid = widget.patientUid ?? int.tryParse(await _apiService.getUserId() ?? '');
    _loadTreatments();
  }

  Future<void> _loadTreatments() async {
    setState(() { _isLoading = true; });
    try {
      final treatments = await _apiService.getPatientTreatments(uid: _uid);
      setState(() {
        _treatments = List<Map<String, dynamic>>.from(treatments);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addTreatment() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _apiService.addPatientTreatment(uid: _uid, data: {'text': _textController.text});
      _textController.clear();
      _loadTreatments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Treatment added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add treatment: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Treatments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _treatments.isEmpty
                  ? const Center(child: Text('No treatments found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _treatments.length,
                      itemBuilder: (context, index) {
                        final c = _treatments[index];
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
                                    const Icon(Icons.healing, color: Colors.teal),
                                    const SizedBox(width: 8),
                                    Text('Treatment', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.teal)),
                                    const Spacer(),
                                    if (c['createdAt'] != null)
                                      Text(
                                        c['createdAt'].toString().split('T').first,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text('${c['treatment'] ?? ''}${c['name'] != null ? ' - ' + c['name'] : ''}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                                if (c['dose'] != null) Text('Dose: ${c['dose']}'),
                                if (c['route'] != null) Text('Route: ${c['route']}'),
                                if (c['frequency_text'] != null) Text('Frequency: ${c['frequency_text']}'),
                                if (c['Time_Period'] != null) Text('Duration: ${c['Time_Period']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 