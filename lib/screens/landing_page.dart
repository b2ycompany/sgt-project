import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
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
  final PageController _carouselController = PageController();
  late AnimationController _waveController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    // Motor de animação para as ondas de fundo surrealistas
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Timer para o carrossel automático de ativos de luxo
    Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _carouselController.dispose();
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
          // CAMADA 0: Fundo de Ondas Matemáticas (Dinamismo Surreal)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return CustomPaint(
                    painter: BackgroundWavePainter(_waveController.value));
              },
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. INDICADORES GLOBAIS: Ticker de Mercado Bloomberg-Style
              SliverToBoxAdapter(
                child: Container(
                  height: 45,
                  color: Colors.black.withValues(alpha: 0.8),
                  child: _buildGlobalTicker(gold),
                ),
              ),

              // 2. HERO SECTION: Carrossel de Impacto Cinematográfico
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Stack(
                    children: [
                      PageView(
                        controller: _carouselController,
                        children: [
                          _buildHeroSlide(
                              "Oportunidades Off-Market",
                              "Acesse lotes exclusivos em áreas de alta valorização antes do mercado aberto.",
                              "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070",
                              gold),
                          _buildHeroSlide(
                              "Segurança Jurídica USA",
                              "Patrimônio dolarizado sob jurisdição americana sólida e transparente.",
                              "https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=1973",
                              gold),
                          _buildHeroSlide(
                              "Gestão de Fortuna",
                              "Estratégia desenhada para proteção patrimonial e lucro real em Dólar.",
                              "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070", // Link Corrigido
                              gold),
                        ],
                      ),
                      // Gradiente de profundidade inferior
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              navy.withValues(alpha: 0.9),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 60,
                        left: 50,
                        child: _buildHeroCTA(context, gold, navy),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. INDICADORES DE PERFORMANCE: Contadores Dinâmicos (Glassmorphism)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
                  child: Column(
                    children: [
                      Text("POWERED BY INTELLIGENCE",
                          style: GoogleFonts.cinzel(
                              color: gold,
                              fontSize: 14,
                              letterSpacing: 5,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 60),
                      Wrap(
                        spacing: 30,
                        runSpacing: 30,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildCounterCard(
                              "ROI MÉDIO ANUAL", 24.8, "% a.a.", emerald),
                          _buildCounterCard(
                              "ASSETS UNDER MGMT", 45.2, "M USD", Colors.white),
                          _buildCounterCard(
                              "INVESTIDORES PRIVATE", 1250, "+", gold),
                          _buildCounterCard(
                              "LANCES ATIVOS", 128, " Unid.", Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 4. METODOLOGIA: Fluxo de Investimento CIG
              SliverToBoxAdapter(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 100, horizontal: 40),
                  color: Colors.white.withValues(alpha: 0.02),
                  child: Column(
                    children: [
                      Text("O FLUXO DE INVESTIMENTO",
                          style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Container(width: 80, height: 2, color: gold),
                      const SizedBox(height: 80),
                      _buildWorkflowStep("01", "DUE DILIGENCE NEURAL",
                          "Algoritmos que analisam milhares de lotes para encontrar o 1% com maior potencial de retorno."),
                      _buildWorkflowStep("02", "AQUISIÇÃO E ESTRUTURA",
                          "Compra direta com proteção jurídica completa e registro imediato em nome do grupo/investidor."),
                      _buildWorkflowStep("03", "VALORIZAÇÃO E EXIT",
                          "Monitoramento de mercado para venda estratégica e liquidação com lucro maximizado."),
                    ],
                  ),
                ),
              ),

              // 5. ÁREA DE MEMBROS E SEGURANÇA
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 120),
                  child: Column(
                    children: [
                      const Icon(Icons.shield_outlined, color: gold, size: 60),
                      const SizedBox(height: 30),
                      Text("MEMBERS PRIVILEGED ACCESS",
                          style: GoogleFonts.cinzel(
                              color: Colors.white24,
                              fontSize: 16,
                              letterSpacing: 4)),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen())),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 60, vertical: 25),
                        ),
                        child: const Text("ENTRAR NO PORTAL CIG"),
                      ),
                      const SizedBox(height: 120),
                      const Text(
                          "© 2026 CIG PRIVATE INVESTMENT • US ASSET MANAGEMENT",
                          style: TextStyle(
                              color: Colors.white10,
                              fontSize: 10,
                              letterSpacing: 2)),
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

  // --- COMPONENTES DE LAYOUT ---

  Widget _buildGlobalTicker(Color gold) {
    final List<String> indicators = [
      "S&P 500: 5,120.4 (+1.2%)",
      "GOLD: \$2,154.20 (+0.5%)",
      "USD/BRL: R\$ 5,42 (-0.3%)",
      "FLORIDA LAND INDEX: +14.2% YTD",
      "US TREASURY 10Y: 4.22%",
      "CIG ALPHA ROI: 24.8% a.a."
    ];

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 20, // Loop infinito simulado
      itemBuilder: (context, index) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              indicators[index % indicators.length],
              style: GoogleFonts.robotoMono(
                  color: gold, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroSlide(String title, String sub, String imgUrl, Color gold) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imgUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              const Color(0xFF050F22).withValues(alpha: 0.7), BlendMode.darken),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              SizedBox(
                width: 650,
                child: Text(sub,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: gold.withValues(alpha: 0.8),
                        fontSize: 18,
                        height: 1.5,
                        fontWeight: FontWeight.w300)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCTA(BuildContext context, Color gold, Color navy) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
          ),
          child: const Text("SOLICITAR ACESSO EXCLUSIVO"),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.green),
            const SizedBox(width: 10),
            Text("12 NOVAS OFERTAS DISPONÍVEIS",
                style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterCard(
      String label, double value, String suffix, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(45),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 20),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: value),
                duration: const Duration(seconds: 4),
                builder: (context, double val, child) {
                  return Text(
                    "${val.toStringAsFixed(1)}$suffix",
                    style: GoogleFonts.cinzel(
                        color: color,
                        fontSize: 42,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(num,
              style: GoogleFonts.cinzel(
                  color: const Color(0xFFD4AF37),
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 14, height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PINTOR DE ONDAS DINÂMICAS (SURREALISMO MATEMÁTICO)
class BackgroundWavePainter extends CustomPainter {
  final double value;
  BackgroundWavePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 6; i++) {
      final path = Path();
      final yOffset = size.height * (0.2 + (i * 0.12));
      path.moveTo(0, yOffset);

      for (var x = 0.0; x <= size.width; x++) {
        final y = yOffset +
            math.sin((x / size.width * 2 * math.pi) +
                    (value * 2 * math.pi) +
                    i) *
                40;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundWavePainter oldDelegate) => true;
}
