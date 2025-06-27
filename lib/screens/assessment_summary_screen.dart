import 'package:flutter/material.dart';
import '../models/joint.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentSummaryScreen extends StatelessWidget {
  final Set<String> selectedSwollenJoints;
  final Set<String> selectedTenderJoints;
  final double patientGlobalAssessment;
  final double evaluatorGlobalAssessment;
  final double cReactiveProtein;
  final List<Joint> allJoints;

  const AssessmentSummaryScreen({
    super.key,
    required this.selectedSwollenJoints,
    required this.selectedTenderJoints,
    required this.patientGlobalAssessment,
    required this.evaluatorGlobalAssessment,
    required this.cReactiveProtein,
    required this.allJoints,
  });

  double _calculateSDAI() {
    return selectedSwollenJoints.length + // SJC (Swollen Joint Count)
           selectedTenderJoints.length + // TJC (Tender Joint Count)
           patientGlobalAssessment + // Patient Global Assessment (0-10)
           evaluatorGlobalAssessment + // Evaluator Global Assessment (0-10)
           cReactiveProtein; // CRP (0-10)
  }

  String _getSDAICategory(double score) {
    if (score <= 3.3) return 'Remission';
    if (score <= 11) return 'Low Disease Activity';
    if (score <= 26) return 'Moderate Disease Activity';
    return 'High Disease Activity';
  }

  Future<void> _saveAssessment(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiService = ApiService(prefs);
      await apiService.saveDiseaseScore({
        'swollenJoints': selectedSwollenJoints.toList(),
        'tenderJoints': selectedTenderJoints.toList(),
        'patientGlobalAssessment': patientGlobalAssessment,
        'evaluatorGlobalAssessment': evaluatorGlobalAssessment,
        'cReactiveProtein': cReactiveProtein,
        'score': _calculateSDAI(),
        'category': _getSDAICategory(_calculateSDAI()),
        'date': DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assessment saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save assessment: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sdaiScore = _calculateSDAI();
    final category = _getSDAICategory(sdaiScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Summary'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SDAI Score',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sdaiScore.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: _getCategoryColor(category),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildScoreItem('Swollen Joints', selectedSwollenJoints.length.toDouble()),
                              _buildScoreItem('Tender Joints', selectedTenderJoints.length.toDouble()),
                              _buildScoreItem('Patient Global', patientGlobalAssessment),
                              _buildScoreItem('Evaluator Global', evaluatorGlobalAssessment),
                              _buildScoreItem('CRP', cReactiveProtein),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Joints',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedSwollenJoints.isNotEmpty) ...[
                      const Text(
                        'Swollen Joints:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSwollenJoints.map((joint) => Chip(
                          label: Text(joint),
                          backgroundColor: Colors.red.shade100,
                          labelStyle: TextStyle(color: Colors.red.shade900),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (selectedTenderJoints.isNotEmpty) ...[
                      const Text(
                        'Tender Joints:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedTenderJoints.map((joint) => Chip(
                          label: Text(joint),
                          backgroundColor: Colors.orange.shade100,
                          labelStyle: TextStyle(color: Colors.orange.shade900),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _saveAssessment(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Remission':
        return Colors.green;
      case 'Low Disease Activity':
        return Colors.lightGreen;
      case 'Moderate Disease Activity':
        return Colors.orange;
      case 'High Disease Activity':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}