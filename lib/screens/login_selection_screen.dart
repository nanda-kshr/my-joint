import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_login_screen.dart';
import 'patient_login_screen.dart';
import 'dart:ui' show ImageFilter;

class LoginSelectionScreen extends StatefulWidget {
  const LoginSelectionScreen({super.key});

  @override
  State<LoginSelectionScreen> createState() => _LoginSelectionScreenState();
}

class _LoginSelectionScreenState extends State<LoginSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String _selectedLanguage = 'en';

  // Cached gradient and decorations
  static const _backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF667eea),
      Color(0xFF764ba2),
      Color(0x99667eea),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.6, 1.0],
  );

  static final _cardDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(32),
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.25),
        Colors.white.withOpacity(0.1),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 40,
        offset: const Offset(0, 20),
      ),
    ],
  );

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
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    _controller.forward();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _selectedLanguage = prefs.getString('language') ?? 'en';
      });
    }
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
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: Stack(
          children: [
            // Simplified particle effect
            const _ParticleBackground(),
            
            // Glass overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            
            SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: _buildMainContent(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: _cardDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 12),
                  _buildSubtitle(),
                  const SizedBox(height: 48),
                  _buildButtons(),
                  const SizedBox(height: 32),
                  _buildFooterText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Image.asset(
          'images/myjoints_logo512x512.png',
          fit: BoxFit.cover,
          errorBuilder: (ctx, e, st) => Icon(
            Icons.medical_services,
            color: Colors.white.withOpacity(0.9),
            size: 50,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white, Color(0xE6FFFFFF)],
      ).createShader(bounds),
      child: Text(
        _selectedLanguage == 'en' 
            ? 'Welcome to MyJoints' 
            : 'MyJoints இல் வரவேற்கிறோம்',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      _selectedLanguage == 'en' 
          ? 'Secure access for Patients & Doctors' 
          : 'நோயாளிகள் மற்றும் மருத்தர்களுக்கான பாதுகாப்பான அணுகல்',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 15,
        color: Colors.white.withOpacity(0.7),
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        _buildButton(
          icon: Icons.person,
          label: _selectedLanguage == 'en' ? 'Patient Login' : 'நோயாளர் உள்நுழைவு',
          colors: const [Color(0xFF42A5F5), Color(0xFF1976D2)],
          onTap: () => _navigateToScreen(const PatientLoginScreen()),
        ),
        const SizedBox(height: 16),
        _buildButton(
          icon: Icons.medical_services,
          label: _selectedLanguage == 'en' ? 'Doctor Login' : 'மருத்துவர் உள்நுழைவு',
          colors: const [Color(0xFF5C6BC0), Color(0xFF3F51B5)],
          onTap: () => _navigateToScreen(const DoctorLoginScreen()),
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: colors),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.first.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        _selectedLanguage == 'en'
            ? 'Need an account? Register from the login screens.'
            : 'கணக்கு தேவையா? உள்நுழைவு திரைகளில் பதிவு செய்யவும்.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.white.withOpacity(0.8),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => screen,
        transitionsBuilder: (context, animation, _, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _ParticleBackground extends StatefulWidget {
  const _ParticleBackground();

  @override
  State<_ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<_ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(
        painter: _OptimizedParticlesPainter(_controller.value),
        size: MediaQuery.of(context).size,
      ),
    );
  }
}

class _OptimizedParticlesPainter extends CustomPainter {
  final double animationValue;
  static const int particleCount = 30;

  _OptimizedParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int i = 0; i < particleCount; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final x = size.width * (0.1 + 0.8 * ((i * 0.7 + progress) % 1.0));
      final y = size.height * (0.1 + 0.8 * ((i * 0.3 + progress * 0.5) % 1.0));
      final opacity = (0.1 + 0.2 * (1 - (progress - 0.5).abs() * 2)).clamp(0.0, 0.3);
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(_OptimizedParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}