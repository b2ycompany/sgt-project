import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgt_projeto/screens/login_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _scrollEffectController;

  @override
  void initState() {
    super.initState();
    _scrollEffectController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _scrollEffectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const navy = Color(0xFF050F22);
    const emerald = Color(0xFF2E8B57);

    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          // FUNDO: Gradiente de Profundidade Nativo
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [Color(0xFF0A1931), navy],
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. HERO SECTION: O Impacto Inicial
              SliverToBoxAdapter(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildShimmerText(
                        "PREMIER US LAND ACQUISITION",
                        GoogleFonts.poppins(
                          color: gold.withValues(alpha: 0.8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Onde o Capital\nEncontra a Solidez.",
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize:
                              MediaQuery.of(context).size.width > 600 ? 72 : 42,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: 600,
                        child: Text(
                          "Inteligência imobiliária exclusiva para investidores brasileiros. Ativos lastreados em Dólar nos mercados de maior valorização dos Estados Unidos.",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 18,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 25),
                          backgroundColor: gold,
                          elevation: 20,
                        ),
                        child: Text(
                          "ENTRAR NA ÁREA EXCLUSIVA",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. INDICADORES DINÂMICOS (Métricas de Performance)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
                  child: Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildMetricCard("ROI MÉDIO ANUAL", 24.8, "%", emerald),
                      _buildMetricCard(
                          "TEMPO P/ FATURAMENTO", 18, " Meses", gold),
                      _buildMetricCard(
                          "VALOR EM GESTÃO", 45.2, "M USD", Colors.white),
                    ],
                  ),
                ),
              ),

              // 3. GRÁFICO DE CRESCIMENTO NEURAL (Custom Painter Nativo)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: gold.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "PROJEÇÃO DE APRECIAÇÃO DO ATIVO",
                        style: GoogleFonts.cinzel(
                            color: gold, fontSize: 18, letterSpacing: 2),
                      ),
                      const SizedBox(height: 60),
                      SizedBox(
                        height: 300,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: GrowthGraphPainter(emerald, gold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. ÁREA PARA MEMBROS E SEGURANÇA
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(100),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [navy, Colors.black],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          color: gold, size: 60),
                      const SizedBox(height: 30),
                      Text(
                        "MEMBERS ONLY",
                        style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Ambiente criptografado. Acesso restrito a cotistas CIG Private.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38),
                      ),
                      const SizedBox(height: 40),
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        ),
                        child: Text(
                          "EFETUAR LOGIN PRIVADO →",
                          style: TextStyle(
                              color: gold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget para texto com efeito de brilho suave (Shimmer Nativo)
  Widget _buildShimmerText(String text, TextStyle style) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.white24, Colors.white, Colors.white24],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(text, style: style),
    );
  }

  // Card com efeito Glassmorphism e Contador Animado
  Widget _buildMetricCard(
      String label, double value, String suffix, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: value),
                duration: const Duration(seconds: 3),
                builder: (context, double val, child) {
                  return Text(
                    "${val.toStringAsFixed(1)}$suffix",
                    style: GoogleFonts.cinzel(
                      color: color,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pintor Nativo para o Gráfico de Crescimento Financeiro
class GrowthGraphPainter extends CustomPainter {
  final Color mainColor;
  final Color accentColor;
  GrowthGraphPainter(this.mainColor, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.75,
      size.width * 0.5,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.1,
      size.width,
      0,
    );

    // Efeito de Brilho na Linha
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..color = mainColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
