import 'package:flutter/material.dart';
import 'package:my_joints/screens/forgot_password_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_joints/services/api_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_selection_screen.dart';
import 'screens/patient_login_screen.dart';
import 'screens/doctor_login_screen.dart';
import 'screens/patient_dashboard_screen.dart';
import 'screens/doctor_dashboard_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    Provider<ApiService>(
      create: (_) => ApiService(prefs),
      child: const MyApp(),
    ),
  );
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
        '/': (context) => const SplashScreen(),
        '/login-selection': (context) => const LoginSelectionScreen(),
        '/patient-login': (context) => const PatientLoginScreen(),
        '/doctor-login': (context) => const DoctorLoginScreen(),
        '/patient-register': (context) => const PatientLoginScreen(isRegister: true),
        '/doctor-register': (context) => const DoctorLoginScreen(isRegister: true),
        '/patient-dashboard': (context) => const PatientDashboardScreen(),
        '/doctor-dashboard': (context) => const DoctorDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
      },
    );
  }
}