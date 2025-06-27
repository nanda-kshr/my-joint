import 'package:flutter/material.dart';
import 'joint_assessment_screen.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  double _painLevel = 0;
  final List<String> _painDescriptions = [
    'No Pain',
    'Mild Pain',
    'Moderate Pain',
    'Severe Pain',
    'Very Severe Pain',
    'Worst Pain Possible',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Assessment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.calculate, size: 32),
                title: const Text(
                  'Calculate SDAI Score',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Assess joint inflammation and disease activity'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const JointAssessmentScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Pain Assessment',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
                      'How would you rate your pain level?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _getPainColor(_painLevel),
                        inactiveTrackColor: Colors.grey[300],
                        thumbColor: _getPainColor(_painLevel),
                        overlayColor: _getPainColor(_painLevel).withOpacity(0.2),
                        valueIndicatorColor: _getPainColor(_painLevel),
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      child: Slider(
                        value: _painLevel,
                        min: 0,
                        max: 5,
                        divisions: 5,
                        label: _painDescriptions[_painLevel.toInt()],
                        onChanged: (value) {
                          setState(() {
                            _painLevel = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => Text(
                          index.toString(),
                          style: TextStyle(
                            color: _getPainColor(index.toDouble()),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
                      'Pain Scale Guidelines',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGuidelineItem(
                      '0 - No Pain',
                      'You are completely pain-free',
                      Colors.green,
                    ),
                    _buildGuidelineItem(
                      '1-2 - Mild Pain',
                      'Noticeable but not interfering with daily activities',
                      Colors.lightGreen,
                    ),
                    _buildGuidelineItem(
                      '3-4 - Moderate Pain',
                      'Interferes with some activities but can still function',
                      Colors.orange,
                    ),
                    _buildGuidelineItem(
                      '5-6 - Severe Pain',
                      'Significantly interferes with daily activities',
                      Colors.deepOrange,
                    ),
                    _buildGuidelineItem(
                      '7-8 - Very Severe Pain',
                      'Unable to perform most activities',
                      Colors.red,
                    ),
                    _buildGuidelineItem(
                      '9-10 - Worst Pain Possible',
                      'Completely unable to function, requires immediate attention',
                      Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Save assessment to database
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Assessment saved successfully'),
                    ),
                  );
                },
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

  Widget _buildGuidelineItem(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPainColor(double value) {
    if (value <= 1) return Colors.green;
    if (value <= 2) return Colors.lightGreen;
    if (value <= 3) return Colors.orange;
    if (value <= 4) return Colors.deepOrange;
    if (value <= 5) return Colors.red;
    return Colors.purple;
  }
} 