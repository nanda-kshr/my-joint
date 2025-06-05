import 'package:flutter/material.dart';
import 'package:my_joints/screens/joint_assessment_screen.dart';
import 'screens/login_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joint Assessment Mannequin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const JointAssessmentScreen(),
    );
  }
}