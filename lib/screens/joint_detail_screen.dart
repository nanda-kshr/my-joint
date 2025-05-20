import 'package:flutter/material.dart';
import '../models/joint_assessment.dart';

class JointDetailScreen extends StatefulWidget {
  final String jointName;
  
  const JointDetailScreen({super.key, required this.jointName});
  
  @override
  State<JointDetailScreen> createState() => _JointDetailScreenState();
}

class _JointDetailScreenState extends State<JointDetailScreen> {
  int painLevel = 0;
  String rangeOfMotion = "Normal";
  final TextEditingController notesController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.jointName} Assessment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pain Level (0-10)', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: painLevel.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: painLevel.toString(),
              onChanged: (value) {
                setState(() {
                  painLevel = value.toInt();
                });
              },
            ),
            
            const SizedBox(height: 16),
            Text('Range of Motion', style: Theme.of(context).textTheme.titleMedium),
            DropdownButton<String>(
              value: rangeOfMotion,
              isExpanded: true,
              items: ["Normal", "Limited", "Severely Limited"]
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    rangeOfMotion = newValue;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            Text('Notes', style: Theme.of(context).textTheme.titleMedium),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter assessment notes',
              ),
            ),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Create assessment data
                  final assessment = JointAssessment(
                    jointName: widget.jointName,
                    painLevel: painLevel,
                    rangeOfMotion: rangeOfMotion,
                    notes: notesController.text,
                  );
                  
                  // Here you would typically save this data
                  // For now, just return to previous screen
                  Navigator.pop(context);
                  
                  // Show a confirmation snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${widget.jointName} assessment saved'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('Save Assessment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}