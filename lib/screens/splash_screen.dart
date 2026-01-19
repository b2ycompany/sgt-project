import 'dart:async';
import 'dart:math';
import 'dart:ui'; // Adicionado: Necessário para ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgt_projeto/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _textBlur;

  @override
  void initState() {
    super.initState();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.2, 0.5, curve: Curves.easeIn)),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.2, 0.6, curve: Curves.elasticOut)),
    );

    _textBlur = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.5, 0.9, curve: Curves.easeOut)),
    );

    _mainController.forward();

    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthWrapper(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050F22),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleController.value),
                );
              },
            ),
          ),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  // Corrigido: Kent para gradient
                  colors: [
                    const Color(0xFFD4AF37)
                        .withValues(alpha: 0.15), // Corrigido: withValues
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: _logoOpacity.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFFD4AF37)
                                    .withValues(alpha: 0.5),
                                width: 1), // Corrigido: withValues
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(
                                    alpha: 0.2), // Corrigido: withValues
                                blurRadius: 40,
                                spreadRadius: 10,
                              )
                            ],
                          ),
                          child: const Icon(Icons.account_balance,
                              size: 80, color: Color(0xFFD4AF37)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    ImageFiltered(
                      imageFilter: ImageFilter.blur(
                          sigmaX: _textBlur.value, sigmaY: _textBlur.value),
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Column(
                          children: [
                            Text(
                              "CIG PRIVATE",
                              style: GoogleFonts.cinzel(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 10,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "INTELLIGENCE & CAPITAL",
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFD4AF37),
                                fontSize: 12,
                                letterSpacing: 5,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
          .withValues(alpha: 0.2); // Corrigido: withValues
    final nodes = <Offset>[];
    final random = Random(42);

    for (var i = 0; i < 40; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      x += sin(animationValue * 2 * pi + i) * 20;
      y += cos(animationValue * 2 * pi + i) * 20;
      nodes.add(Offset(x, y));
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }

    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final distance = (nodes[i] - nodes[j]).distance;
        if (distance < 150) {
          canvas.drawLine(
            nodes[i],
            nodes[j],
            Paint()
              ..color = const Color(0xFFD4AF37).withValues(
                  alpha: 1 - (distance / 150)) // Corrigido: withValues
              ..strokeWidth = 0.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
