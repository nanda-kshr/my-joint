import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientInvestigationsScreen extends StatefulWidget {
  final int? patientUid;
  const PatientInvestigationsScreen({super.key, this.patientUid});

  @override
  State<PatientInvestigationsScreen> createState() => _PatientInvestigationsScreenState();
}

class _PatientInvestigationsScreenState extends State<PatientInvestigationsScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _investigations = [];
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
    _loadInvestigations();
  }

  Future<void> _loadInvestigations() async {
    setState(() { _isLoading = true; });
    try {
      final investigations = await _apiService.getPatientInvestigations(uid: _uid);
      setState(() {
        _investigations = List<Map<String, dynamic>>.from(investigations);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addInvestigation() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _apiService.addPatientInvestigation(uid: _uid, data: {'text': _textController.text});
      _textController.clear();
      _loadInvestigations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Investigation added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add investigation: $e')),
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
        title: const Text('Investigations', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _investigations.isEmpty
                  ? const Center(child: Text('No investigations found.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _investigations.length,
                      itemBuilder: (context, index) {
                        final c = _investigations[index];
                        final fields = c.entries
                          .where((e) => e.key != 'id' && e.key != 'uid' && e.key != 'createdAt' && e.value != null && e.value.toString().trim().isNotEmpty)
                          .toList();
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
                                    const Icon(Icons.science, color: Colors.deepPurple),
                                    const SizedBox(width: 8),
                                    Text('Investigation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.deepPurple)),
                                    const Spacer(),
                                    if (c['createdAt'] != null)
                                      Text(
                                        c['createdAt'].toString().split('T').first,
                                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (fields.isNotEmpty)
                                  ...fields.map<Widget>((e) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.circle, size: 8, color: Colors.deepPurple),
                                            const SizedBox(width: 6),
                                            Expanded(child: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 15))),
                                          ],
                                        ),
                                      )),
                                if (fields.isEmpty)
                                  const Text('No data', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
} 