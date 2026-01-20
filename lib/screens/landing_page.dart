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
    // Auto-play do carrossel
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const navy = Color(0xFF050F22);

    return Scaffold(
      backgroundColor: navy,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. TICKER DE MERCADO (Indicadores em Tempo Real)
          SliverToBoxAdapter(
            child: Container(
              height: 40,
              color: gold.withOpacity(0.1),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildTickerItem("USD/BRL: R\$ 5,42 (+0.2%)"),
                  _buildTickerItem("FLORIDA LAND INDEX: +12.4%"),
                  _buildTickerItem("US TREASURY 10Y: 4.22%"),
                  _buildTickerItem("SGT ALPHA ROI: 24.8% a.a."),
                ],
              ),
            ),
          ),

          // 2. HERO & CARROSSEL DE ATIVOS
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Stack(
                children: [
                  PageView(
                    controller: _carouselController,
                    children: [
                      _buildCarouselItem("Acquisição de Terrenos",
                          "Estratégia Off-Market nos EUA"),
                      _buildCarouselItem("Valorização Patrimonial",
                          "Ativos lastreados em Dólar"),
                      _buildCarouselItem(
                          "Segurança CIG", "Gestão Private para Brasileiros"),
                    ],
                  ),
                  Positioned(
                    bottom: 40,
                    left: 40,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen())),
                      child: const Text("INVESTIR AGORA"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. INDICADORES RODANDO (Rolling Numbers)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildRollingMetric("TOTAL INVESTIDO", 45.2, "M USD"),
                  _buildRollingMetric("RETORNO MÉDIO", 24.8, "% a.a."),
                  _buildRollingMetric("TERRENOS EM GESTÃO", 850, "+"),
                ],
              ),
            ),
          ),

          // 4. FLUXO DE INVESTIMENTO (Como funciona)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
              child: Column(
                children: [
                  Text("FLUXO DE INVESTIMENTO",
                      style: GoogleFonts.cinzel(
                          color: gold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 40),
                  _buildWorkflowStep("01", "ANÁLISE",
                      "Identificação de lotes com alto potencial de valorização."),
                  _buildWorkflowStep("02", "AQUISIÇÃO",
                      "Processo jurídico e documental 100% seguro nos EUA."),
                  _buildWorkflowStep("03", "VALORIZAÇÃO",
                      "Gestão ativa do ativo até o momento ideal de saída."),
                ],
              ),
            ),
          ),

          // 5. PORTAL DE MEMBROS
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(80),
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, color: gold, size: 50),
                  const SizedBox(height: 20),
                  const Text("ÁREA EXCLUSIVA PARA COTISTAS",
                      style:
                          TextStyle(color: Colors.white38, letterSpacing: 2)),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen())),
                    child: const Text("LOGIN PRIVADO →",
                        style: TextStyle(
                            color: gold, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTickerItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Text(text,
          style: GoogleFonts.robotoMono(
              color: const Color(0xFFD4AF37),
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCarouselItem(String title, String sub) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            colors: [Color(0xFF050F22), Color(0xFF142850)],
            begin: Alignment.topLeft),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(sub,
                style: GoogleFonts.poppins(
                    color: const Color(0xFFD4AF37), fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildRollingMetric(String label, double value, String suffix) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 15),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(seconds: 4),
            builder: (context, double val, child) {
              return Text("${val.toStringAsFixed(1)}$suffix",
                  style: GoogleFonts.cinzel(
                      color: const Color(0xFFD4AF37),
                      fontSize: 32,
                      fontWeight: FontWeight.bold));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          Text(num,
              style: GoogleFonts.cinzel(
                  color: const Color(0xFFD4AF37),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
