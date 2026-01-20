import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgt_projeto/screens/login_screen.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final PageController _carouselController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Inicia o carrossel automático
    Timer.periodic(const Duration(seconds: 7), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOutSine,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const navy = Color(0xFF050F22);
    const emerald = Color(0xFF2E8B57);

    return Scaffold(
      backgroundColor: navy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. TICKER: Indicadores de Mercado ao Vivo
          SliverToBoxAdapter(
            child: Container(
              height: 40,
              color: gold.withValues(alpha: 0.08),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTickerItem("USD/BRL: R\$ 5,42 (+0.3%)"),
                  _buildTickerItem("FLORIDA LAND INDEX: +14.2%"),
                  _buildTickerItem("US TREASURY 10Y: 4.25%"),
                  _buildTickerItem("SGT ALPHA RETURN: 24.8% a.a."),
                  _buildTickerItem("MIAMI REAL ESTATE: HIGH DEMAND"),
                ],
              ),
            ),
          ),

          // 2. HERO: Carrossel Cinematográfico com Imagens Fixas
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Stack(
                children: [
                  PageView(
                    controller: _carouselController,
                    children: [
                      _buildHeroSlide(
                          "Capitalização USA",
                          "Investimentos imobiliários em jurisdição de alta confiança e solidez.",
                          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070"),
                      _buildHeroSlide(
                          "Oportunidades Off-Market",
                          "Acesse lotes exclusivos em áreas de alta valorização antes do mercado aberto.",
                          "https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=1973"),
                      _buildHeroSlide(
                          "Gestão de Fortuna",
                          "Estratégia desenhada para proteção patrimonial e lucro real em Dólar.",
                          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070"),
                    ],
                  ),
                  // Overlay de Gradiente para leitura
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
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen())),
                      child: const Text("ACESSO EXCLUSIVO PARA MEMBROS"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. MÉTRICAS: Indicadores de Performance (Rolling Numbers)
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
              child: Column(
                children: [
                  Text("PERFORMANCE AUDITADA",
                      style: GoogleFonts.cinzel(
                          color: gold, fontSize: 18, letterSpacing: 4)),
                  const SizedBox(height: 60),
                  Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildGlassMetric("ROI MÉDIO", 24.8, "% a.a.", emerald),
                      _buildGlassMetric(
                          "TEMPO P/ FATURAMENTO", 18, " Meses", gold),
                      _buildGlassMetric(
                          "VALOR EM GESTÃO", 45.2, "M USD", Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. WORKFLOW: Fluxo de Investimento Inteligente
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(80),
              color: Colors.white.withValues(alpha: 0.02),
              child: Column(
                children: [
                  Text("INTELIGÊNCIA CIG PRIVATE",
                      style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 80),
                  _buildWorkflowStep("01", "ANÁLISE NEURAL",
                      "Identificamos lotes subvalorizados através de algoritmos proprietários de Big Data nos EUA."),
                  _buildWorkflowStep("02", "PROTEÇÃO JURÍDICA",
                      "Estrutura 100% legal e transparente. Propriedades registradas em jurisdição segura."),
                  _buildWorkflowStep("03", "VALORIZAÇÃO E SAÍDA",
                      "Gestão ativa do ativo e venda estratégica no pico de valorização para maximização de lucro."),
                ],
              ),
            ),
          ),

          // 5. FOOTER: Login Privado e Segurança
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 100),
              child: Column(
                children: [
                  const Icon(Icons.verified_user_outlined,
                      color: gold, size: 50),
                  const SizedBox(height: 30),
                  Text("MEMBERS PRIVILEGED ACCESS",
                      style: GoogleFonts.cinzel(
                          color: Colors.white24,
                          fontSize: 14,
                          letterSpacing: 4)),
                  const SizedBox(height: 40),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen())),
                    child: const Text("LOGIN PRIVADO →",
                        style: TextStyle(
                            color: gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                  const SizedBox(height: 120),
                  const Text(
                      "© 2026 CIG PRIVATE INVESTMENT • USA ASSET MANAGEMENT",
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
    );
  }

  Widget _buildTickerItem(String t) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(t,
                style: GoogleFonts.robotoMono(
                    color: const Color(0xFFD4AF37),
                    fontSize: 11,
                    fontWeight: FontWeight.bold))));
  }

  Widget _buildHeroSlide(String t, String s, String img) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(img),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                const Color(0xFF050F22).withValues(alpha: 0.65),
                BlendMode.darken)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 54,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              SizedBox(
                  width: 600,
                  child: Text(s,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: const Color(0xFFD4AF37),
                          fontSize: 18,
                          height: 1.5))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassMetric(String l, double v, String s, Color c) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(45),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Column(
            children: [
              Text(l,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 20),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: v),
                duration: const Duration(seconds: 4),
                builder: (context, double val, child) {
                  return Text("${val.toStringAsFixed(1)}$s",
                      style: GoogleFonts.cinzel(
                          color: c, fontSize: 44, fontWeight: FontWeight.bold));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkflowStep(String n, String t, String d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n,
              style: GoogleFonts.cinzel(
                  color: const Color(0xFFD4AF37),
                  fontSize: 36,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Text(d,
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
