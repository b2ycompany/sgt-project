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

    // Motor de animação para as ondas de fundo
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Carrossel automático cinematográfico
    Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1500),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 900;

          return Stack(
            children: [
              // FUNDO DINÂMICO
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
                  // 1. TICKER DE MERCADO BLOOMBERG
                  SliverToBoxAdapter(
                    child: Container(
                      height: 45,
                      color: Colors.black.withValues(alpha: 0.85),
                      child: _buildGlobalTicker(gold),
                    ),
                  ),

                  // 2. HERO SECTION ADAPTATIVA
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.75
                          : MediaQuery.of(context).size.height * 0.9,
                      child: Stack(
                        children: [
                          PageView(
                            controller: _carouselController,
                            children: [
                              _buildHeroSlide(
                                  "Oportunidades Off-Market",
                                  "Acesse lotes exclusivos em áreas de alta valorização antes do mercado aberto.",
                                  "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070",
                                  gold,
                                  isMobile),
                              _buildHeroSlide(
                                  "Segurança Jurídica USA",
                                  "Patrimônio dolarizado sob jurisdição americana sólida e transparente.",
                                  "https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=1973",
                                  gold,
                                  isMobile),
                              _buildHeroSlide(
                                  "Gestão de Fortuna",
                                  "Estratégia desenhada para proteção patrimonial e lucro real em Dólar.",
                                  "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070",
                                  gold,
                                  isMobile),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [navy, Colors.transparent],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: isMobile ? 50 : 80,
                            left: isMobile ? 30 : 80,
                            child: _buildHeroCTA(context, gold, navy, isMobile),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. ESTRATÉGIA DE DOLARIZAÇÃO
                  SliverToBoxAdapter(
                    child: _buildDollarizationSection(gold, isMobile),
                  ),

                  // 4. PERFORMANCE KPIs
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 80 : 120, horizontal: 20),
                      child: Column(
                        children: [
                          Text("POWERED BY INTELLIGENCE",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                  color: gold,
                                  fontSize: isMobile ? 12 : 14,
                                  letterSpacing: 5,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 60),
                          Wrap(
                            spacing: 30,
                            runSpacing: 30,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildCounterCard("ROI MÉDIO ANUAL", 24.8,
                                  "% a.a.", emerald, isMobile),
                              _buildCounterCard("ASSETS UNDER MGMT", 45.2,
                                  "M USD", Colors.white, isMobile),
                              _buildCounterCard("INVESTIDORES PRIVATE", 1250,
                                  "+", gold, isMobile),
                              _buildCounterCard("LANCES ATIVOS", 128, " Unid.",
                                  Colors.white, isMobile),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. METODOLOGIA DE FLUXO
                  SliverToBoxAdapter(
                    child: _buildMethodologySection(gold, isMobile),
                  ),

                  // 6. DEPOIMENTOS DE MEMBROS (NOVA SEÇÃO)
                  SliverToBoxAdapter(
                    child: _buildTestimonialsSection(gold, isMobile),
                  ),

                  // 7. ECOSSISTEMA E SEGURANÇA
                  SliverToBoxAdapter(
                    child: _buildEcosystemSection(gold, isMobile),
                  ),

                  // 8. FAQ EXECUTIVO
                  SliverToBoxAdapter(
                    child: _buildFAQSection(gold, isMobile),
                  ),

                  // 9. RODAPÉ INSTITUCIONAL
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 140),
                      child: Column(
                        children: [
                          const Icon(Icons.shield_outlined,
                              color: gold, size: 60),
                          const SizedBox(height: 30),
                          Text("MEMBERS PRIVILEGED ACCESS",
                              style: GoogleFonts.cinzel(
                                  color: Colors.white24,
                                  fontSize: 14,
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
                              "© 2026 CIG PRIVATE INVESTMENT • GLOBAL ASSET MANAGEMENT",
                              textAlign: TextAlign.center,
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
          );
        },
      ),
    );
  }

  // --- NOVOS MÓDULOS DE CONTEÚDO ---

  Widget _buildTestimonialsSection(Color gold, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 80 : 150, horizontal: isMobile ? 30 : 100),
      color: Colors.white.withValues(alpha: 0.01),
      child: Column(
        children: [
          Text("VOZES DA ELITE",
              style: GoogleFonts.cinzel(
                  color: gold,
                  fontSize: 14,
                  letterSpacing: 6,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text("DEPOIMENTOS DE MEMBROS PRIVATE",
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 80),
          isMobile
              ? Column(children: _getTestimonials(gold))
              : Row(
                  children: _getTestimonials(gold)
                      .map((e) => Expanded(child: e))
                      .toList(),
                ),
        ],
      ),
    );
  }

  List<Widget> _getTestimonials(Color gold) {
    return [
      _testimonialCard(
        "Marcus V.",
        "Investidor Private",
        "A estratégia da CIG me permitiu dolarizar meu patrimônio com uma segurança que eu não encontrava em corretoras comuns.",
        "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
        gold,
      ),
      _testimonialCard(
        "Ana L.",
        "Asset Management",
        "O portal de transparência e o acompanhamento dos lotes em tempo real são os grandes diferenciais do grupo.",
        "https://images.unsplash.com/photo-1494790108377-be9c29b29330",
        gold,
      ),
      _testimonialCard(
        "Ricardo S.",
        "Tech Founder",
        "Dolarização é o hedge definitivo. Com a CIG, o processo de land banking tornou-se acessível e altamente rentável.",
        "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
        gold,
      ),
    ];
  }

  Widget _testimonialCard(
      String name, String role, String quote, String imgUrl, Color gold) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(imgUrl),
            backgroundColor: gold.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 30),
          Text("\"$quote\"",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.8)),
          const SizedBox(height: 30),
          Text(name.toUpperCase(),
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(role,
              style: const TextStyle(
                  color: Colors.white24, fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }

  Widget _buildDollarizationSection(Color gold, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 80 : 120, horizontal: isMobile ? 30 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("POR QUE DOLARIZAR PATRIMÔNIO?",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(width: 80, height: 3, color: gold),
          const SizedBox(height: 60),
          isMobile
              ? Column(children: _dollarizationCards(gold))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _dollarizationCards(gold)
                      .map((e) => Expanded(child: e))
                      .toList(),
                ),
        ],
      ),
    );
  }

  List<Widget> _dollarizationCards(Color gold) {
    return [
      _infoCard(Icons.trending_down, "Hedge Cambial",
          "Proteja seu capital da volatilidade de moedas emergentes alocando em Dólar."),
      _infoCard(Icons.security, "Jurisdição Forte",
          "Seus ativos estão sob as leis de propriedade privada dos EUA, as mais seguras do mundo."),
      _infoCard(Icons.public, "Diversificação Global",
          "Não dependa apenas da economia local. O mercado imobiliário USA é o porto seguro global."),
    ];
  }

  Widget _infoCard(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFFD4AF37), size: 45),
          const SizedBox(height: 25),
          Text(title,
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(desc,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 14, height: 1.7)),
        ],
      ),
    );
  }

  Widget _buildMethodologySection(Color gold, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 80 : 120, horizontal: isMobile ? 30 : 60),
      color: Colors.white.withValues(alpha: 0.02),
      child: Column(
        children: [
          Text("O FLUXO DE INVESTIMENTO",
              textAlign: TextAlign.center,
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: isMobile ? 24 : 32,
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
    );
  }

  Widget _buildEcosystemSection(Color gold, bool isMobile) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 140, horizontal: isMobile ? 30 : 100),
      child: Row(
        children: [
          if (!isMobile)
            Expanded(
                child: Icon(Icons.hub_outlined,
                    color: gold.withValues(alpha: 0.05), size: 450)),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ECOSSISTEMA SGT",
                    style: GoogleFonts.cinzel(
                        color: gold,
                        fontSize: 14,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text("TRANSPARÊNCIA E GOVERNANÇA BANCÁRIA",
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: isMobile ? 24 : 40,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 50),
                _ecosystemItem("Auditoria Real-Time",
                    "Acompanhe seus lances e lucros em tempo real via dashboard de elite."),
                _ecosystemItem("Conformidade Legal",
                    "Estrutura alinhada com as normas de compliance SEC e jurisdição USA."),
                _ecosystemItem("Suporte Concierge",
                    "Atendimento exclusivo e personalizado para membros do grupo private."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ecosystemItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              color: Color(0xFFD4AF37), size: 26),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17)),
                const SizedBox(height: 10),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 15, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFAQSection(Color gold, bool isMobile) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 120, horizontal: isMobile ? 30 : 120),
      color: Colors.black.withValues(alpha: 0.4),
      child: Column(
        children: [
          Text("PERGUNTAS FREQUENTES",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 80),
          _faqTile("Qual o aporte mínimo inicial?",
              "O grupo foca em investidores qualificados com aportes estruturados a partir de \$50.000 USD."),
          _faqTile("Qual a liquidez média do investimento?",
              "O ciclo completo entre aquisição estratégica e exit costuma durar de 18 a 36 meses."),
          _faqTile("Como recebo meus rendimentos?",
              "Os lucros são creditados diretamente na sua conta bancária internacional indicada após a liquidação do ativo."),
        ],
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: ExpansionTile(
        title: Text(question,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        iconColor: Color(0xFFD4AF37),
        collapsedIconColor: Colors.white24,
        children: [
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(answer,
                style: const TextStyle(
                    color: Colors.white38, height: 1.8, fontSize: 14)),
          )
        ],
      ),
    );
  }

  // --- MÓDULOS ORIGINAIS PRESERVADOS ---

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
      itemCount: 20,
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

  Widget _buildHeroSlide(
      String title, String sub, String imgUrl, Color gold, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imgUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              const Color(0xFF050F22).withValues(alpha: 0.75),
              BlendMode.darken),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: isMobile ? 38 : 64,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              SizedBox(
                width: isMobile ? double.infinity : 750,
                child: Text(sub,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: gold.withValues(alpha: 0.9),
                        fontSize: isMobile ? 15 : 20,
                        height: 1.6,
                        fontWeight: FontWeight.w300)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCTA(
      BuildContext context, Color gold, Color navy, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 35 : 50, vertical: 28),
          ),
          child: const Text("SOLICITAR ACESSO EXCLUSIVO"),
        ),
        const SizedBox(height: 25),
        Row(
          children: [
            const Icon(Icons.circle, size: 8, color: Colors.green),
            const SizedBox(width: 12),
            Text("12 NOVAS OFERTAS DISPONÍVEIS",
                style: GoogleFonts.poppins(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.8)),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterCard(
      String label, double value, String suffix, Color color, bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.42 : 300,
          padding: EdgeInsets.all(isMobile ? 30 : 50),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5)),
              const SizedBox(height: 25),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: value),
                duration: const Duration(seconds: 5),
                builder: (context, double val, child) {
                  return Text(
                    "${val.toStringAsFixed(1)}$suffix",
                    style: GoogleFonts.cinzel(
                        color: color,
                        fontSize: isMobile ? 26 : 46,
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
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(num,
              style: GoogleFonts.cinzel(
                  color: const Color(0xFFD4AF37),
                  fontSize: 42,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 45),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 1.8)),
                const SizedBox(height: 12),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 15, height: 1.7)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PINTOR DE ONDAS DINÂMICAS
class BackgroundWavePainter extends CustomPainter {
  final double value;
  BackgroundWavePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (var i = 0; i < 7; i++) {
      final path = Path();
      final yOffset = size.height * (0.15 + (i * 0.13));
      path.moveTo(0, yOffset);

      for (var x = 0.0; x <= size.width; x++) {
        final y = yOffset +
            math.sin((x / size.width * 2 * math.pi) +
                    (value * 2 * math.pi) +
                    i) *
                50;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundWavePainter oldDelegate) => true;
}
