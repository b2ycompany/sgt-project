import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgt_projeto/screens/landing_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _textTranslateAnim;

  @override
  void initState() {
    super.initState();
    // Configuração das animações em cadeia para efeito premium
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)));

    _textTranslateAnim = Tween<double>(begin: 50.0, end: 0.0).animate(
        CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic)));

    _controller.forward();

    // Transição suave após 4 segundos
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LandingPage(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ));
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
    final accentGold = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Gradiente de Luxo Profundo
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050F22), // Almost Black Blue
              Color(0xFF0A1931), // Deep Navy
              Color(0xFF142850), // Rich Blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone com efeito de brilho dourado
                  Opacity(
                    opacity: _opacityAnim.value,
                    child: Transform.scale(
                      scale: _scaleAnim.value,
                      child: Container(
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: accentGold.withOpacity(0.5), width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: accentGold.withOpacity(0.3),
                                blurRadius: 50,
                                spreadRadius: 5)
                          ],
                        ),
                        child:
                            Icon(Icons.auto_graph, size: 80, color: accentGold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Texto com entrada deslizante
                  Transform.translate(
                    offset: Offset(0, _textTranslateAnim.value),
                    child: Opacity(
                      opacity: _opacityAnim.value,
                      child: Column(
                        children: [
                          Text(
                            "CIG PRIVATE",
                            style: GoogleFonts.cinzel(
                              // Fonte clássica para luxo
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                            ),
                          ),
                          Text(
                            "US REAL ESTATE INTELLIGENCE",
                            style: GoogleFonts.poppins(
                              color: accentGold,
                              fontSize: 12,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
