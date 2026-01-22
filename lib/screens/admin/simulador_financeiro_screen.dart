import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

/// Módulo de Inteligência Financeira v2.5 - CIG Private INVESTMENT
/// Simulador Híbrido Corrigido: Caracteres ilegais e imports redundantes removidos.
/// Suporta Projeção de ROI Dinâmica e Visualização Gráfica de Patrimônio.
class SimuladorFinanceiroScreen extends StatefulWidget {
  const SimuladorFinanceiroScreen({super.key});

  @override
  State<SimuladorFinanceiroScreen> createState() =>
      _SimuladorFinanceiroScreenState();
}

class _SimuladorFinanceiroScreenState extends State<SimuladorFinanceiroScreen> {
  // Parâmetros de Simulação Operacional
  double _capitalDeAporte = 100000;
  double _taxaProjetadaRoi = 24.8;
  int _cicloDeMeses = 24;

  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  Widget build(BuildContext context) {
    debugPrint(
        "--- [SGT LOG]: Simulador recalculando projeções patrimoniais ---");

    // Cálculo de Performance Financeira
    double lucroEstimado =
        _capitalDeAporte * (_taxaProjetadaRoi / 100) * (_cicloDeMeses / 12);
    double montanteFinal = _capitalDeAporte + lucroEstimado;

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("FINANCIAL SIMULATOR",
            style: GoogleFonts.cinzel(
                color: gold,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 3)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(50),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSimuladorHeader(),
            const SizedBox(height: 60),

            // PAINEL DE CONTROLES (SLIDERS)
            _buildParametrosPanel(),
            const SizedBox(height: 70),

            // RESULTADOS MÉTRICOS (Corrigido para evitar caracteres ilegais)
            _buildResultadosMetricasFinal(lucroEstimado, montanteFinal),
            const SizedBox(height: 70),

            // PROGRESSÃO GRÁFICA
            _buildPerformanceGrowthChart(montanteFinal),
            const SizedBox(height: 120),

            _buildRegulatoryFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSimuladorHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ASSET PROJECTION ENGINE • v2.5.0",
            style: TextStyle(
                color: gold.withValues(alpha: 0.4),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 15),
        Text("SIMULADOR DE RENDIMENTOS",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        const Text(
            "Cálculo de performance patrimonial baseado no portfólio Land Banking e Oportunidades USA.",
            style: TextStyle(color: Colors.white38, fontSize: 16, height: 1.6)),
      ],
    );
  }

  Widget _buildParametrosPanel() {
    return Container(
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          _buildSliderItem("CAPITAL DE APORTE (USD)", _capitalDeAporte, 50000,
              2000000, (v) => setState(() => _capitalDeAporte = v),
              isMoney: true),
          const SizedBox(height: 60),
          _buildSliderItem("TARGET ROI (% A.A.)", _taxaProjetadaRoi, 10, 45,
              (v) => setState(() => _taxaProjetadaRoi = v)),
          const SizedBox(height: 60),
          _buildSliderItem("PRAZO DO CICLO (MESES)", _cicloDeMeses.toDouble(),
              6, 48, (v) => setState(() => _cicloDeMeses = v.toInt())),
        ],
      ),
    );
  }

  Widget _buildSliderItem(
      String label, double value, double min, double max, Function(double) onC,
      {bool isMoney = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            Text(
                isMoney
                    ? "\$ ${value.toStringAsFixed(0)}"
                    : "${value.toStringAsFixed(1)}${label.contains('%') ? '%' : ''}",
                style: GoogleFonts.robotoMono(
                    color: gold, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
            value: value,
            min: min,
            max: max,
            activeColor: gold,
            inactiveColor: Colors.white10,
            onChanged: onC),
      ],
    );
  }

  /// Nome corrigido: Removido 'é' para compatibilidade total
  Widget _buildResultadosMetricasFinal(double lucro, double total) {
    return Wrap(
      spacing: 35,
      runSpacing: 35,
      children: [
        _cardResultadoTile(
            "LUCRO BRUTO PROJETADO", "\$ ${lucro.toStringAsFixed(2)}", emerald),
        _cardResultadoTile("MONTANTE LÍQUIDO FINAL",
            "\$ ${total.toStringAsFixed(2)}", Colors.white),
      ],
    );
  }

  Widget _cardResultadoTile(String label, String value, Color color) {
    return Container(
      width: 380,
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 20),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: color, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPerformanceGrowthChart(double total) {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(50),
      decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PROGRESSÃO DO PATRIMÔNIO NO CICLO",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 60),
          Expanded(
            child: LineChart(LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                      spots: [
                        const FlSpot(0, 0),
                        FlSpot(_cicloDeMeses.toDouble(), total),
                      ],
                      isCurved: true,
                      color: gold,
                      barWidth: 5,
                      belowBarData: BarAreaData(
                          show: true, color: gold.withValues(alpha: 0.08)))
                ])),
          ),
        ],
      ),
    );
  }

  Widget _buildRegulatoryFooter() {
    return const Center(
      child: Column(
        children: [
          Text("© 2026 CIG PRIVATE INVESTMENT GROUP • FLORIDA USA",
              style: TextStyle(
                  color: Colors.white10, fontSize: 9, letterSpacing: 3)),
          SizedBox(height: 10),
          Text("ESTA SIMULAÇÃO NÃO REPRESENTA GARANTIA DE LUCRO.",
              style: TextStyle(
                  color: Colors.white10, fontSize: 7, letterSpacing: 1)),
        ],
      ),
    );
  }
}
