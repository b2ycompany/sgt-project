import 'package:flutter/material.dart';
import 'package:countup/countup.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgt_projeto/screens/login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildMetricsGrid(),
            _buildROILogic(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  // Hero Section: Introdução da CIG
  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E), // Cor institucional
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
      ),
      child: Column(
        children: [
          Text("Plataforma de Alta Performance",
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const Text(
              "Tecnologia integrada para maximizar o rendimento de ativos imobiliários.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const LoginScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853), // Verde performativo
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("ACESSO PARA MEMBROS",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Seção de Contadores Animados
  Widget _buildMetricsGrid() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          _metricCard("VALOR GERADO", "R\$ ", 1250000, "Milhões"),
          _metricCard("ROI MÉDIO", "", 24, "% a.a"),
          _metricCard("ATIVOS GESTÃO", "", 450, "Unidades"),
          _metricCard("TEMPO MÉDIO", "", 18, "Meses p/ Faturamento"),
        ],
      ),
    );
  }

  Widget _metricCard(String label, String prefix, double value, String suffix) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
          ]),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(prefix,
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E))),
              Countup(
                begin: 0,
                end: value,
                duration: const Duration(seconds: 3),
                separator: '.',
                style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A237E)),
              ),
            ],
          ),
          Text(suffix,
              style: const TextStyle(
                  color: Color(0xFF00C853), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Gráfico de Projeção de ROI
  Widget _buildROILogic(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(40),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Evolução do Investimento vs. ROI",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 1.5),
                      FlSpot(2, 2.8),
                      FlSpot(3, 3.5),
                      FlSpot(4, 5)
                    ],
                    isCurved: true,
                    color: const Color(0xFF1A237E),
                    barWidth: 5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF1A237E).withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(60),
      color: Colors.black87,
      child: const Center(
        child: Text(
            "SGT CIG Investimento © 2026 - Melhores Práticas de Mercado",
            style: TextStyle(color: Colors.white54, fontSize: 12)),
      ),
    );
  }
}
