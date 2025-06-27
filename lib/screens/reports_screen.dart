import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildReportCard(
            'Pain Assessment History',
            'View your pain level assessments over time',
            Icons.assessment,
            Colors.blue,
          ),
          _buildReportCard(
            'Exercise Progress',
            'Track your exercise completion and improvements',
            Icons.fitness_center,
            Colors.green,
          ),
          _buildReportCard(
            'Diet Tracking',
            'Monitor your meal plan adherence',
            Icons.restaurant_menu,
            Colors.orange,
          ),
          _buildReportCard(
            'Consultation History',
            'View past doctor consultations',
            Icons.video_call,
            Colors.purple,
          ),
          _buildReportCard(
            'Medication History',
            'Track your medication usage',
            Icons.medication,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to detailed report
        },
      ),
    );
  }
} 