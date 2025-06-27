import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDiseaseScoresScreen extends StatefulWidget {
  const PatientDiseaseScoresScreen({super.key});

  @override
  State<PatientDiseaseScoresScreen> createState() => _PatientDiseaseScoresScreenState();
}

class _PatientDiseaseScoresScreenState extends State<PatientDiseaseScoresScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _diseaseScores = [];

  @override
  void initState() {
    super.initState();
    _initializeApiService();
  }

  Future<void> _initializeApiService() async {
    final prefs = await SharedPreferences.getInstance();
    _apiService = ApiService(prefs);
    _loadDiseaseScores();
  }

  Future<void> _loadDiseaseScores() async {
    try {
      final diseaseScores = await _apiService.getPatientDiseaseScores();
      setState(() {
        _diseaseScores = List<Map<String, dynamic>>.from(diseaseScores);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Disease Scores'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _diseaseScores.length,
                  itemBuilder: (context, index) {
                    final score = _diseaseScores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(score['type']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Score: ${score['score']}'),
                            Text('Date: ${score['date']}'),
                            Text('Interpretation: ${score['interpretation']}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 