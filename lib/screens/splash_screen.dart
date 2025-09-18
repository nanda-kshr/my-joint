import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_joints/services/api_service.dart';
import 'package:provider/provider.dart';
import 'dart:ui' show ImageFilter;
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  
  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _pulseAnimation;

  // Cached gradient and decorations
  static const _backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF059669), // Patient emerald
      Color(0xFF10B981), // Patient green
      Color(0xFF3B82F6), // Doctor blue
      Color(0xFF1E3A8A), // Doctor deep blue
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static final _logoDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(35),
    gradient: LinearGradient(
      colors: [
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0.1),
        Colors.blue.withOpacity(0.2),
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
        color: Colors.black.withOpacity(0.15),
        blurRadius: 25,
        offset: const Offset(0, 12),
      ),
      BoxShadow(
        color: Colors.blue.withOpacity(0.2),
        blurRadius: 30,
        offset: const Offset(0, 0),
      ),
    ],
  );

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );
    
    _logoScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _logoRotation = Tween<double>(
      begin: -0.3,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack),
    ));
    
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));
    
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }
  
  void _startAnimationSequence() async {
    _particleController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _mainController.forward();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    _pulseController.repeat(reverse: true);
    
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;
    
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final isLoggedIn = await apiService.isTokenValid();
      
      if (!mounted) return;
      
      if (isLoggedIn) {
        final userType = await apiService.getUserType();
        final routeName = userType == 'patient' 
            ? '/patient-dashboard'
            : userType == 'doctor'
                ? '/doctor-dashboard'
                : '/login-selection';
        Navigator.of(context).pushReplacementNamed(routeName);
      } else {
        Navigator.of(context).pushReplacementNamed('/login-selection');
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login-selection');
      }
    }
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: Stack(
          children: [
            const _OptimizedParticleSystem(),
            _buildGlassOverlay(),
            SafeArea(
              child: Center(
                child: AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnimatedLogo(),
                      const SizedBox(height: 50),
                      _buildAnimatedText(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.03),
            Colors.transparent,
            Colors.white.withOpacity(0.01),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value * _pulseAnimation.value,
          child: Transform.rotate(
            angle: _logoRotation.value,
            child: Container(
              width: 140,
              height: 140,
              decoration: _logoDecoration,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(33),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.blue.withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRotatingRing(),
                        const Icon(
                          Icons.medical_services,
                          size: 60,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingRing() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Transform.rotate(
          angle: _particleController.value * 2 * math.pi,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedText() {
    return SlideTransition(
      position: _textSlide,
      child: FadeTransition(
        opacity: _textOpacity,
        child: Column(
          children: [
            _buildTitle(),
            const SizedBox(height: 12),
            _buildSubtitle(),
            const SizedBox(height: 60),
            _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'MyJoints',
      style: TextStyle(
        fontSize: 38,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Text(
        'Comprehensive Joint Care',
        style: TextStyle(
          fontSize: 16,
          color: Colors.white.withOpacity(0.9),
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                  ),
                );
              },
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w300,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _OptimizedParticleSystem extends StatefulWidget {
  const _OptimizedParticleSystem();

  @override
  State<_OptimizedParticleSystem> createState() => _OptimizedParticleSystemState();
}

class _OptimizedParticleSystemState extends State<_OptimizedParticleSystem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 25),
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
  static const int particleCount = 40;
  static const int orbCount = 3;

  _OptimizedParticlesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    _paintParticles(canvas, size);
    _paintOrbs(canvas, size);
  }

  void _paintParticles(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (int i = 0; i < particleCount; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final x = size.width * (0.1 + 0.8 * math.sin(progress * 2 * math.pi + i));
      final y = size.height * (0.1 + 0.8 * math.cos(progress * 1.5 * math.pi + i * 0.7));
      final opacity = (0.05 + 0.15 * math.sin(progress * math.pi)).clamp(0.0, 0.2);
      final radius = 1.0 + math.sin(animationValue * 3 + i) * 0.5;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  void _paintOrbs(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    
    for (int i = 0; i < orbCount; i++) {
      final x = size.width * (0.3 + 0.4 * math.sin(animationValue * 0.3 + i * 2));
      final y = size.height * (0.3 + 0.4 * math.cos(animationValue * 0.2 + i * 1.5));
      final radius = (25 + 10 * math.sin(animationValue * 2 + i));
      final opacity = (0.05 + 0.03 * math.sin(animationValue * 1.5 + i)).clamp(0.0, 0.08);
      
      paint.color = [
        Colors.blue,
        Colors.indigo,
        Colors.purple,
      ][i].withOpacity(opacity);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_OptimizedParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}