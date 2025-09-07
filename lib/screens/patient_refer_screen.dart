import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientReferScreen extends StatefulWidget {
  final String? patientUid;
  const PatientReferScreen({super.key, this.patientUid});

  @override
  State<PatientReferScreen> createState() => _PatientReferScreenState();
}

class _PatientReferScreenState extends State<PatientReferScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _referrals = [];
  String? _userRole;
  String? _uid;
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
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
    _userRole = await _apiService.getUserType();
    _uid = widget.patientUid ?? await _apiService.getUserId() ?? '';
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    setState(() { _isLoading = true; });
    try {
      final referrals = await _apiService.getPatientReferrals(uid: _uid);
      setState(() {
        _referrals = List<Map<String, dynamic>>.from(referrals);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addReferral() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _apiService.addPatientReferral(uid: _uid, text: _textController.text);
      _textController.clear();
      _loadReferrals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add referral: $e')),
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
        title: Text(_selectedLanguage == 'en' ? 'Referrals' : 'ரெஃபரல்கள்'),
      ),
      floatingActionButton: _userRole == 'doctor'
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Add Referral'),
                    content: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _textController,
                            decoration: const InputDecoration(labelText: 'Referral'),
                            validator: (value) => value == null || value.isEmpty ? 'Enter a value' : null,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _addReferral,
                              child: const Text('Add Referral'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                );
              },
              tooltip: 'Add Referral',
              child: const Icon(Icons.add),
            )
          : null,
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
        : _referrals.isEmpty
          ? Center(child: Text(_selectedLanguage == 'en' ? 'No referrals found.' : 'ரெஃபரல்கள் இல்லை.'))
                  : ListView.builder(
                      itemCount: _referrals.length,
                      itemBuilder: (context, index) {
                        final c = _referrals[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(c['text'] ?? ''),
                            subtitle: Text('Added: ${c['createdAt'] ?? ''}'),
                          ),
                        );
                      },
                    ),
    );
  }
} 