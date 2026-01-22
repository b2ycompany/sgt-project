import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

/// Módulo de Inteligência Financeira v2.1 - CIG Private
/// Simulador Híbrido para Projeção de Ativos USA e Land Banking.
/// Versão Corrigida: Removido caracteres ilegais e imports desnecessários.
class SimuladorFinanceiroScreen extends StatefulWidget {
  const SimuladorFinanceiroScreen({super.key});

  @override
  State<SimuladorFinanceiroScreen> createState() =>
      _SimuladorFinanceiroScreenState();
}

class _SimuladorFinanceiroScreenState extends State<SimuladorFinanceiroScreen> {
  // Parâmetros Dinâmicos da Simulação
  double _capitalBase = 100000;
  double _taxaRoiAnual = 24.8;
  int _cicloMeses = 24;

  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  Widget build(BuildContext context) {
    debugPrint("--- [SGT LOG]: Recalculando Projeção Financeira ---");

    // Lógica Matemática de Capitalização
    double lucroEstimado =
        _capitalBase * (_taxaRoiAnual / 100) * (_cicloMeses / 12);
    double montanteFinal = _capitalBase + lucroEstimado;

    return Scaffold(
      backgroundColor: navy,
      appBar: _buildSimAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSimHeader(),
            const SizedBox(height: 50),

            // CONTROLES DE ENTRADA
            _buildParametrosCard(),
            const SizedBox(height: 60),

            // RESULTADOS VISUAIS (Função renomeada para evitar erro 'é')
            _buildResultadosMetricas(lucroEstimado, montanteFinal),
            const SizedBox(height: 60),

            // ANÁLISE GRÁFICA DE CRESCIMENTO
            _buildChartSection(montanteFinal),
            const SizedBox(height: 100),

            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSimAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildSimHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ASSET PROJECTION ENGINE • 2026",
            style: TextStyle(
                color: gold.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 12),
        Text("SIMULAR RENDIMENTOS",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text(
          "Defina os parâmetros do aporte para projetar a performance do capital no mercado imobiliário americano.",
          style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildParametrosCard() {
    return Container(
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          _buildSliderInput(
              "CAPITAL DE APORTE (USD)", _capitalBase, 50000, 2000000, (v) {
            setState(() => _capitalBase = v);
          }, isCurrency: true),
          const SizedBox(height: 50),
          _buildSliderInput("TARGET ROI (% A.A.)", _taxaRoiAnual, 10, 45, (v) {
            setState(() => _taxaRoiAnual = v);
          }),
          const SizedBox(height: 50),
          _buildSliderInput(
              "PRAZO DO CICLO (MESES)", _cicloMeses.toDouble(), 6, 48, (v) {
            setState(() => _cicloMeses = v.toInt());
          }),
        ],
      ),
    );
  }

  Widget _buildSliderInput(String label, double current, double min, double max,
      Function(double) onChanged,
      {bool isCurrency = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2)),
            Text(
              isCurrency
                  ? "\$ ${current.toStringAsFixed(0)}"
                  : "${current.toStringAsFixed(1)}${label.contains('%') ? '%' : ''}",
              style: GoogleFonts.robotoMono(
                  color: gold, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: current,
          min: min,
          max: max,
          activeColor: gold,
          inactiveColor: Colors.white10,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Nome corrigido: métricas -> metricas
  Widget _buildResultadosMetricas(double lucro, double total) {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children: [
        _metricTile(
            "LUCRO BRUTO PROJETADO", "\$ ${lucro.toStringAsFixed(2)}", emerald),
        _metricTile("MONTANTE TOTAL LÍQUIDO", "\$ ${total.toStringAsFixed(2)}",
            Colors.white),
      ],
    );
  }

  Widget _metricTile(String label, String val, Color c) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 15),
          Text(val,
              style: GoogleFonts.cinzel(
                  color: c, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartSection(double total) {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("PROGRESSÃO DO PATRIMÔNIO (TEMPO X ROI)",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 0),
                      FlSpot(_cicloMeses / 2, total / 1.5),
                      FlSpot(_cicloMeses.toDouble(), total),
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: gold.withValues(alpha: 0.05)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return const Center(
      child: Text(
        "* ESTA SIMULAÇÃO É UMA ESTIMATIVA BASEADA NO HISTÓRICO DE MERCADO E NÃO GARANTE RETORNO FUTURO.",
        style: TextStyle(color: Colors.white10, fontSize: 8, letterSpacing: 2),
      ),
    );
  }
}
