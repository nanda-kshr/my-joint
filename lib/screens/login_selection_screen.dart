import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_login_screen.dart';
import 'patient_login_screen.dart';

class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.indigo.shade50,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        Text(
                          _selectedLanguage == 'en' ? 'Welcome!' : 'வரவேற்கிறோம்!',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue.shade900),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _selectedLanguage == 'en' ? 'Select your role to continue' : 'தொடர உங்கள் வகுப்பை தேர்ந்தெடுக்கவும்',
                          style: const TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.person, size: 28),
                          label: Text(_selectedLanguage == 'en' ? 'Patient Login' : 'நோயாளர் உள்நுழைவு', style: const TextStyle(fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(220, 48),
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const PatientLoginScreen()),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.medical_services, size: 28),
                          label: Text(_selectedLanguage == 'en' ? 'Doctor Login' : 'மருத்துவர் உள்நுழைவு', style: const TextStyle(fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(220, 48),
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DoctorLoginScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

} 