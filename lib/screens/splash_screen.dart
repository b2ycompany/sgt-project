import 'dart:async';
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
  late AnimationController _scannerController;
  late AnimationController _logoController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _shimmerMove;

  @override
  void initState() {
    super.initState();

    // 1. Feixe de luz tecnológico (Scanner)
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // 2. Surgimento e Brilho do Logótipo (WOW Effect)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.3, 0.7, curve: Curves.easeIn)),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.3, 0.7,
              curve: Curves.easeOutBack)), // Corrigido: easeOutBack
    );

    _shimmerMove = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeInOut)),
    );

    _logoController.forward();

    // Transição cinematográfica para o sistema
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthWrapper(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const navyBackground = Color(0xFF050F22);

    return Scaffold(
      backgroundColor: navyBackground,
      body: Stack(
        children: [
          // FUNDO: Gradiente dinâmico de profundidade
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                colors: [Color(0xFF0A1931), navyBackground],
                radius: 1.2,
              ),
            ),
          ),

          // EFEITO 1: Feixe de Scanner (Luz Dourada Vertical)
          AnimatedBuilder(
            animation: _scannerController,
            builder: (context, child) {
              return Positioned(
                top: 0,
                bottom: 0,
                left: _scannerController.value *
                    MediaQuery.of(context).size.width,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: goldColor.withValues(
                            alpha: 0.6), // Corrigido: withValues
                        blurRadius: 25,
                        spreadRadius: 15,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // EFEITO 2: Marca com Shimmer (Brilho de Luxo)
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ícone com Máscara de Brilho Dinâmica
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: const [
                                Colors.transparent,
                                Colors.white,
                                Colors.transparent
                              ],
                              stops: [
                                _shimmerMove.value - 0.2,
                                _shimmerMove.value,
                                _shimmerMove.value + 0.2,
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: Container(
                            padding: const EdgeInsets.all(35),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: goldColor.withValues(alpha: 0.4),
                                  width: 1.5), // Corrigido: withValues
                              boxShadow: [
                                BoxShadow(
                                  color: goldColor.withValues(
                                      alpha: 0.1), // Corrigido: withValues
                                  blurRadius: 40,
                                  spreadRadius: 5,
                                )
                              ],
                            ),
                            child: const Icon(Icons.account_balance,
                                size: 85, color: goldColor),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Tipografia Estilo Private Banking
                        Text(
                          "CIG PRIVATE",
                          style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "EST. 2026 • USA ASSET MANAGEMENT",
                          style: GoogleFonts.poppins(
                            color: goldColor.withValues(
                                alpha: 0.8), // Corrigido: withValues
                            fontSize: 10,
                            letterSpacing: 5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
