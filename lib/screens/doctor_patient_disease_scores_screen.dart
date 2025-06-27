import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DoctorPatientDiseaseScoresScreen extends StatefulWidget {
  final String patientId;

  const DoctorPatientDiseaseScoresScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<DoctorPatientDiseaseScoresScreen> createState() => _DoctorPatientDiseaseScoresScreenState();
}

class _DoctorPatientDiseaseScoresScreenState extends State<DoctorPatientDiseaseScoresScreen> {
  late ApiService _apiService;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _diseaseScores = [];
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _dateController = TextEditingController();
  final _scoreController = TextEditingController();
  final _notesController = TextEditingController();

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
      final scores = await _apiService.getDoctorPatientDiseaseScores(widget.patientId);
      setState(() {
        _diseaseScores = List<Map<String, dynamic>>.from(scores);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addDiseaseScore() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final scoreData = {
        'type': _typeController.text,
        'date': _dateController.text,
        'score': double.parse(_scoreController.text),
        'notes': _notesController.text,
      };

      await _apiService.addDoctorPatientDiseaseScore(widget.patientId, scoreData);
      _clearForm();
      _loadDiseaseScores();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disease score added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add disease score: $e')),
        );
      }
    }
  }

  Future<void> _updateDiseaseScore(String scoreId, Map<String, dynamic> updateData) async {
    try {
      await _apiService.updateDoctorPatientDiseaseScore(widget.patientId, scoreId, updateData);
      _loadDiseaseScores();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disease score updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update disease score: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _typeController.clear();
    _dateController.clear();
    _scoreController.clear();
    _notesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Disease Scores'),
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
                              controller: _typeController,
                              decoration: const InputDecoration(
                                labelText: 'Score Type',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter score type';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                labelText: 'Date',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter date';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _scoreController,
                              decoration: const InputDecoration(
                                labelText: 'Score',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter score';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter notes';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _addDiseaseScore,
                              child: const Text('Add Disease Score'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Disease Score List',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _diseaseScores.length,
                        itemBuilder: (context, index) {
                          final score = _diseaseScores[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(score['type']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Date: ${score['date']}'),
                                  Text('Score: ${score['score']}'),
                                  Text('Notes: ${score['notes']}'),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      final scoreController = TextEditingController(text: score['score'].toString());
                                      final notesController = TextEditingController(text: score['notes']);
                                      return AlertDialog(
                                        title: const Text('Update Disease Score'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              controller: scoreController,
                                              decoration: const InputDecoration(
                                                labelText: 'Score',
                                                border: OutlineInputBorder(),
                                              ),
                                              keyboardType: TextInputType.number,
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller: notesController,
                                              decoration: const InputDecoration(
                                                labelText: 'Notes',
                                                border: OutlineInputBorder(),
                                              ),
                                              maxLines: 3,
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _updateDiseaseScore(
                                                score['id'],
                                                {
                                                  'score': double.parse(scoreController.text),
                                                  'notes': notesController.text,
                                                },
                                              );
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Update'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
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
    _typeController.dispose();
    _dateController.dispose();
    _scoreController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 