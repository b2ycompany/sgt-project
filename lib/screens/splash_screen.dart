import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgt_projeto/screens/landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 20.0, end: 60.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LandingPage(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(seconds: 1),
          ),
        );
      }
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
      backgroundColor: const Color(0xFF050F22),
      body: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [const Color(0xFF142850), const Color(0xFF050F22)],
                radius: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logotipo com Brilho Pulsante Nativo
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withOpacity(0.3),
                        blurRadius: _glowAnimation.value,
                        spreadRadius: _glowAnimation.value / 4,
                      )
                    ],
                  ),
                  child: const Icon(Icons.account_balance,
                      size: 100, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 50),
                Text("CIG PRIVATE",
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8)),
                const SizedBox(height: 10),
                Text("USA REAL ESTATE INTELLIGENCE",
                    style: GoogleFonts.poppins(
                        color: const Color(0xFFD4AF37),
                        fontSize: 12,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w300)),
              ],
            ),
          );
        },
      ),
    );
  }
}
