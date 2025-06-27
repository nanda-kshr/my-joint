import 'package:flutter/material.dart';
import 'screens/login_selection_screen.dart';
import 'screens/patient_login_screen.dart';
import 'screens/doctor_login_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/joint_assessment_screen.dart';
import 'screens/assessment_summary_screen.dart';
import 'screens/diet_screen.dart';
import 'screens/exercise_screen.dart';
import 'screens/consult_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/settings_screen.dart';
import 'models/joint.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Joints',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginSelectionScreen(),
        '/patient-login': (context) => const PatientLoginScreen(),
        '/doctor-login': (context) => const DoctorLoginScreen(),
        '/patient-register': (context) => const PatientLoginScreen(isRegister: true),
        '/doctor-register': (context) => const DoctorLoginScreen(isRegister: true),
        '/patient-dashboard': (context) => const PatientDashboardScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/joint-assessment': (context) => const JointAssessmentScreen(),
        '/diet': (context) => const DietScreen(),
        '/exercise': (context) => const ExerciseScreen(),
        '/consult': (context) => const ConsultScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/assessment-summary') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AssessmentSummaryScreen(
              selectedSwollenJoints: args['selectedSwollenJoints'] as Set<String>,
              selectedTenderJoints: args['selectedTenderJoints'] as Set<String>,
              patientGlobalAssessment: args['patientGlobalAssessment'] as double,
              evaluatorGlobalAssessment: args['evaluatorGlobalAssessment'] as double,
              cReactiveProtein: args['cReactiveProtein'] as double,
              allJoints: args['allJoints'] as List<Joint>,
            ),
          );
        }
        return null;
      },
    );
  }
}