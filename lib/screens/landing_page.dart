import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:countup/countup.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sgt_projeto/screens/login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Cores do Tema
    final darkBlue = Theme.of(context).colorScheme.primary;
    final gold = Theme.of(context).colorScheme.secondary;
    final greenProfit = Theme.of(context).colorScheme.tertiary;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildPremiumHero(context, darkBlue, gold),
            _buildLiveMarketTicker(darkBlue, gold),
            _buildPerformanceMetrics(darkBlue, gold, greenProfit),
            _buildAdvancedGrowthChart(darkBlue, gold, greenProfit),
            _buildInvestmentThesis(darkBlue, gold),
            _buildPremiumFooter(darkBlue, gold),
          ],
        ),
      ),
    );
  }

  // 1. HERO SECTION PREMIUM
  Widget _buildPremiumHero(BuildContext context, Color darkBlue, Color gold) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darkBlue, const Color(0xFF050F22)],
        ),
        // Descomente abaixo se tiver uma imagem de fundo de luxo (ex: assets/images/hero_bg.jpg)
        /*
        image: DecorationImage(
          image: AssetImage('assets/images/hero_bg.jpg'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(darkBlue.withOpacity(0.8), BlendMode.darken),
        ),
        */
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("US LAND ACQUISITION",
                style: GoogleFonts.poppins(
                    color: gold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            const SizedBox(height: 20),
            Text("Maximize seu Patrimônio em Dólar.",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.1)),
            const SizedBox(height: 30),
            Text(
                "Acesso exclusivo a oportunidades 'off-market' de terrenos nos EUA com alto potencial de valorização e proteção cambial.",
                style: GoogleFonts.poppins(
                    color: Colors.white70, fontSize: 18, height: 1.5)),
            const SizedBox(height: 50),
            // Botão de Login Dourado (Call to Action Principal)
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: darkBlue,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        0)), // Borda quadrada = mais institucional
              ),
              icon: const Icon(Icons.lock_outline),
              label: const Text("MEMBER LOGIN / ACESSO AO PORTAL"),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Icon(Icons.verified_user, color: gold, size: 16),
                SizedBox(width: 8),
                Text("Plataforma Segura & Auditada",
                    style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            )
          ],
        ),
      ),
    );
  }

  // 2. FAIXA DE DADOS AO VIVO (Simulação de Ticker)
  Widget _buildLiveMarketTicker(Color darkBlue, Color gold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: gold.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.chartLine, size: 14, color: gold),
          const SizedBox(width: 10),
          Text(
            "LIVE DATA: US LAND INDEX +4.5% YTD  |  FLORIDA DEMAND +12%  |  CIG AVG ROI 24%  |  USD STRENGTHENING",
            style: GoogleFonts.robotoMono(
                color: darkBlue, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // 3. METRICAS DE PERFORMANCE (Com contadores animados)
  Widget _buildPerformanceMetrics(Color darkBlue, Color gold, Color green) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      color: Colors.white,
      child: Column(
        children: [
          Text("Performance Comprovada",
              style: GoogleFonts.cinzel(
                  color: darkBlue, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
              width: 60, height: 3, color: gold), // Linha separadora dourada
          const SizedBox(height: 50),
          Wrap(
            spacing: 30,
            runSpacing: 30,
            alignment: WrapAlignment.center,
            children: [
              _buildLuxuryMetricCard(
                  darkBlue,
                  gold,
                  green,
                  "VALOR SOB GESTÃO (AUM)",
                  "\$ ",
                  45.2,
                  "Milhões",
                  FontAwesomeIcons.sackDollar),
              _buildLuxuryMetricCard(darkBlue, gold, green, "ROI MÉDIO ANUAL",
                  "", 24.8, "% USD", FontAwesomeIcons.chartPie),
              _buildLuxuryMetricCard(darkBlue, gold, green, "FATURAMENTO TOTAL",
                  "\$ ", 12.5, "Milhões", FontAwesomeIcons.moneyBillTrendUp),
              _buildLuxuryMetricCard(darkBlue, gold, green, "TEMPO MÉDIO EXIT",
                  "", 18, "Meses", FontAwesomeIcons.hourglassHalf),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryMetricCard(Color darkBlue, Color gold, Color green,
      String title, String prefix, double value, String suffix, IconData icon) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: gold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
              color: darkBlue.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: gold),
          const SizedBox(height: 20),
          Text(title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: darkBlue.withOpacity(0.6),
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(prefix,
                  style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkBlue)),
              Countup(
                begin: 0,
                end: value,
                duration: const Duration(seconds: 4),
                separator: ',',
                style: GoogleFonts.cinzel(
                    fontSize: 42, fontWeight: FontWeight.bold, color: darkBlue),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(suffix,
              style: GoogleFonts.poppins(
                  color: green, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  // 4. GRÁFICO FINANCEIRO AVANÇADO (Estilo Terminal Bloomberg)
  Widget _buildAdvancedGrowthChart(Color darkBlue, Color gold, Color green) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
      color: const Color(0xFFF4F6F9),
      child: Column(
        children: [
          Text("Projeção de Crescimento Exponencial",
              style: GoogleFonts.cinzel(
                  color: darkBlue, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text("Comparativo: SGT Land Portfolio vs. Investimentos Tradicionais",
              style: TextStyle(color: darkBlue.withOpacity(0.6))),
          const SizedBox(height: 50),
          AspectRatio(
            aspectRatio: 1.7,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: darkBlue.withOpacity(0.08), blurRadius: 20)
                ],
              ),
              padding: const EdgeInsets.all(25),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                        color: darkBlue.withOpacity(0.1), strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              if (val == 0)
                                return Text("ANO 1",
                                    style: TextStyle(
                                        color: darkBlue.withOpacity(0.5),
                                        fontSize: 10));
                              if (val == 5)
                                return Text("ANO 5",
                                    style: TextStyle(
                                        color: darkBlue.withOpacity(0.5),
                                        fontSize: 10));
                              if (val == 10)
                                return Text("ANO 10",
                                    style: TextStyle(
                                        color: darkBlue.withOpacity(0.5),
                                        fontSize: 10));
                              return const Text("");
                            })),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Linha SGT (Ouro/Verde - Crescimento Alto)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(2, 180),
                        FlSpot(5, 350),
                        FlSpot(8, 600),
                        FlSpot(10, 950)
                      ],
                      isCurved: true,
                      color: green,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                                  radius: 6,
                                  color: gold,
                                  strokeWidth: 2,
                                  strokeColor: Colors.white)),
                      belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                              colors: [
                                green.withOpacity(0.3),
                                green.withOpacity(0.0)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                    ),
                    // Linha Tradicional (Azul Escuro - Crescimento Baixo)
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 100),
                        FlSpot(5, 120),
                        FlSpot(10, 150)
                      ],
                      isCurved: true,
                      color: darkBlue.withOpacity(0.3),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 5. TESE DE INVESTIMENTO (Why Us)
  Widget _buildInvestmentThesis(Color darkBlue, Color gold) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
      color: Colors.white,
      child: Column(
        children: [
          Text("A Tese CIG",
              style: GoogleFonts.cinzel(
                  color: darkBlue, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              _buildThesisPoint(
                  darkBlue,
                  gold,
                  FontAwesomeIcons.shieldHalved,
                  "Segurança Jurídica",
                  "Investimento em jurisdição americana com forte proteção à propriedade privada."),
              _buildThesisPoint(
                  darkBlue,
                  gold,
                  FontAwesomeIcons.arrowTrendUp,
                  "Proteção Cambial",
                  "Ativos lastreados em Dólar, protegendo seu capital da volatilidade local."),
              _buildThesisPoint(
                  darkBlue,
                  gold,
                  FontAwesomeIcons.gem,
                  "Ofertas Off-Market",
                  "Acesso a terrenos exclusivos antes que cheguem ao mercado aberto."),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThesisPoint(
      Color darkBlue, Color gold, IconData icon, String title, String desc) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: gold, size: 24),
          ),
          const SizedBox(height: 20),
          Text(title,
              style: GoogleFonts.cinzel(
                  color: darkBlue, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc,
              style: GoogleFonts.poppins(
                  color: darkBlue.withOpacity(0.7), height: 1.6)),
        ],
      ),
    );
  }

  // 6. FOOTER PREMIUM
  Widget _buildPremiumFooter(Color darkBlue, Color gold) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
      color: darkBlue,
      child: Column(
        children: [
          Icon(FontAwesomeIcons.buildingColumns, color: gold, size: 40),
          const SizedBox(height: 20),
          Text("CIG PRIVATE INVESTMENT",
              style: GoogleFonts.cinzel(
                  color: Colors.white, fontSize: 20, letterSpacing: 2)),
          const SizedBox(height: 40),
          Text("© 2026 CIG Investimento. Todos os direitos reservados.",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const SizedBox(height: 10),
          Text(
              "Investimentos imobiliários envolvem riscos. Consulte os termos de uso.",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 11)),
        ],
      ),
    );
  }
}
