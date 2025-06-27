import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientReferScreen extends StatefulWidget {
  const PatientReferScreen({super.key});

  @override
  State<PatientReferScreen> createState() => _PatientReferScreenState();
}

class _PatientReferScreenState extends State<PatientReferScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _referrals = [];
  final _formKey = GlobalKey<FormState>();
  final _friendNameController = TextEditingController();
  final _friendEmailController = TextEditingController();
  final _friendPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadReferrals();
  }

  Future<void> _loadReferrals() async {
    try {
      final referrals = await _apiService.getPatientReferrals();
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

  Future<void> _referFriend() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final referralData = {
        'friendName': _friendNameController.text,
        'friendEmail': _friendEmailController.text,
        'friendPhone': _friendPhoneController.text,
      };

      await _apiService.referPatient(referralData);
      _friendNameController.clear();
      _friendEmailController.clear();
      _friendPhoneController.clear();
      _loadReferrals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Referral sent successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send referral: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Refer a Friend'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _friendNameController,
                              decoration: const InputDecoration(
                                labelText: 'Friend\'s Name',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your friend\'s name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _friendEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Friend\'s Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your friend\'s email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _friendPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Friend\'s Phone',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your friend\'s phone number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _referFriend,
                              child: const Text('Send Referral'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your Referrals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _referrals.length,
                        itemBuilder: (context, index) {
                          final referral = _referrals[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(referral['friendName']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Status: ${referral['status']}'),
                                  Text('Date: ${referral['date']}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _friendNameController.dispose();
    _friendEmailController.dispose();
    _friendPhoneController.dispose();
    super.dispose();
  }
} 