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
    Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
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
          // 1. TICKER DE MERCADO AO VIVO
          SliverToBoxAdapter(
            child: Container(
              height: 35,
              color: gold.withValues(alpha: 0.05),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTicker("USD/BRL: R\$ 5,42 (+0.3%)"),
                  _buildTicker("FLORIDA LAND INDEX: +14.2%"),
                  _buildTicker("US TREASURY 10Y: 4.25%"),
                  _buildTicker("CIG ALPHA RETURN: 24.8% a.a."),
                ],
              ),
            ),
          ),

          // 2. HERO CARROSSEL (Imagens Premium)
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Stack(
                children: [
                  PageView(
                    controller: _carouselController,
                    children: [
                      _buildHeroSlide(
                          "Capitalização USA",
                          "Investimentos imobiliários em jurisdição de alta confiança.",
                          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070"),
                      _buildHeroSlide(
                          "Oportunidades Off-Market",
                          "Acesso exclusivo a ativos antes do mercado público.",
                          "https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=1973"),
                      _buildHeroSlide(
                          "Gestão de Fortuna",
                          "Estratégia desenhada para proteção e lucro em Dólar.",
                          "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070"),
                    ],
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

          // 3. INDICADORES DE PERFORMANCE (Glassmorphism)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
              child: Wrap(
                spacing: 30,
                runSpacing: 30,
                alignment: WrapAlignment.center,
                children: [
                  _buildMetricCard("ROI MÉDIO", 24.8, "% a.a.", emerald),
                  _buildMetricCard("TEMPO P/ FATURAMENTO", 18, " Meses", gold),
                  _buildMetricCard(
                      "VALOR EM GESTÃO", 45.2, "M USD", Colors.white),
                ],
              ),
            ),
          ),

          // 4. GRÁFICO DE CRESCIMENTO & FLUXO
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(60),
              color: Colors.white.withValues(alpha: 0.02),
              child: Column(
                children: [
                  Text("INTELIGÊNCIA CIG PRIVATE",
                      style: GoogleFonts.cinzel(
                          color: gold,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 60),
                  _buildFlowItem("01", "ANÁLISE NEURAL",
                      "Algoritmos proprietários para detecção de lotes subvalorizados."),
                  _buildFlowItem("02", "PROTEÇÃO JURÍDICA",
                      "Estrutura 100% legal e transparente sob as leis americanas."),
                  _buildFlowItem("03", "LIQUIDEZ OTIMIZADA",
                      "Gestão de saída estratégica para maximização de lucro."),
                ],
              ),
            ),
          ),

          // 5. FOOTER & LOGIN
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(100),
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
                            color: gold, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 100),
                  const Text("© 2026 CIG PRIVATE INVESTMENT",
                      style: TextStyle(color: Colors.white10, fontSize: 10)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicker(String t) {
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
                const Color(0xFF050F22).withValues(alpha: 0.75),
                BlendMode.darken)),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(t,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 44,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(s,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: const Color(0xFFD4AF37), fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String l, double v, String s, Color c) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: 300,
          padding: const EdgeInsets.all(40),
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
              const SizedBox(height: 15),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: v),
                duration: const Duration(seconds: 4),
                builder: (context, double val, child) {
                  return Text("${val.toStringAsFixed(1)}$s",
                      style: GoogleFonts.cinzel(
                          color: c, fontSize: 38, fontWeight: FontWeight.bold));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowItem(String n, String t, String d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Text(n,
              style: GoogleFonts.cinzel(
                  color: const Color(0xFFD4AF37),
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                Text(d,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
