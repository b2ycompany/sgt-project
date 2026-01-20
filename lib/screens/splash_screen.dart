import 'dart:async';
import 'dart:math';
import 'dart:ui';
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
  late AnimationController _particleController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _shimmerMove;
  late Animation<double> _textBlur;

  @override
  void initState() {
    super.initState();

    // 1. Motor de Partículas Matemáticas (Background dinâmico)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // 2. Scanner de Luz Dourada (Efeito Bio-Tech)
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    // 3. Sequência de Surgimento do Logotipo
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.2, 0.5, curve: Curves.easeIn)),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack)),
    );

    _shimmerMove = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.6, 1.0, curve: Curves.easeInOut)),
    );

    _textBlur = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.5, 0.9, curve: Curves.easeOut)),
    );

    _logoController.forward();

    // Navegação automática para o Wrapper de Autenticação
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
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const navy = Color(0xFF050F22);

    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          // FUNDO: Rede Neural de Partículas
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                    painter: NeuralParticlePainter(_particleController.value));
              },
            ),
          ),

          // EFEITO: Scanner de Luz Tecnológico
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
                          color: gold.withValues(alpha: 0.6),
                          blurRadius: 25,
                          spreadRadius: 15),
                    ],
                  ),
                ),
              );
            },
          ),

          // CONTEÚDO CENTRAL: Logo e Branding
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
                        // Ícone com Efeito Shimmer
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
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
                              _shimmerMove.value + 0.2
                            ],
                          ).createShader(bounds),
                          blendMode: BlendMode.srcATop,
                          child: Container(
                            padding: const EdgeInsets.all(35),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: gold.withValues(alpha: 0.5),
                                  width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                    color: gold.withValues(alpha: 0.1),
                                    blurRadius: 40,
                                    spreadRadius: 5)
                              ],
                            ),
                            child: const Icon(Icons.account_balance,
                                size: 90, color: gold),
                          ),
                        ),
                        const SizedBox(height: 50),
                        // Branding com Efeito de Blur Dinâmico
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: _textBlur.value, sigmaY: _textBlur.value),
                          child: Column(
                            children: [
                              Text(
                                "CIG PRIVATE",
                                style: GoogleFonts.cinzel(
                                    color: Colors.white,
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 14),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "US REAL ESTATE INTELLIGENCE",
                                style: GoogleFonts.poppins(
                                    color: gold.withValues(alpha: 0.7),
                                    fontSize: 10,
                                    letterSpacing: 6,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
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

// CustomPainter para criar a rede neural de investimento no fundo
class NeuralParticlePainter extends CustomPainter {
  final double animationValue;
  NeuralParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.15);
    final random = Random(42);
    final nodes = <Offset>[];

    // Gera nós de rede
    for (var i = 0; i < 40; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      x += sin(animationValue * 2 * pi + i) * 25;
      y += cos(animationValue * 2 * pi + i) * 25;
      nodes.add(Offset(x, y));
      canvas.drawCircle(Offset(x, y), 1.5, paint);
    }

    // Desenha conexões neurais
    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < 180) {
          canvas.drawLine(
            nodes[i],
            nodes[j],
            Paint()
              ..color = const Color(0xFFD4AF37)
                  .withValues(alpha: 0.05 * (1 - dist / 180))
              ..strokeWidth = 0.5,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
