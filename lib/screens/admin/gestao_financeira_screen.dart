import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class GestaoFinanceiraScreen extends StatefulWidget {
  const GestaoFinanceiraScreen({super.key});

  @override
  State<GestaoFinanceiraScreen> createState() => _GestaoFinanceiraScreenState();
}

class _GestaoFinanceiraScreenState extends State<GestaoFinanceiraScreen> {
  // Paleta de Luxo Institucional
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          "GESTÃO FINANCEIRA GLOBAL",
          style: GoogleFonts.cinzel(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinanceHeader(),
            const SizedBox(height: 40),

            // --- BLOCO 1: KPIs FINANCEIROS ---
            _buildFinancialKPIs(),
            const SizedBox(height: 50),

            // --- BLOCO 2: GRÁFICO DE CRESCIMENTO PATRIMONIAL ---
            _buildGrowthChartSection(),
            const SizedBox(height: 50),

            // --- BLOCO 3: FLUXO DE CAIXA RECENTE ---
            Text(
              "ÚLTIMAS MOVIMENTAÇÕES",
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CIG ASSET MANAGEMENT",
          style: TextStyle(
            color: gold.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "RELATÓRIO DE LIQUIDEZ",
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialKPIs() {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      children: [
        _financeCard("TOTAL EM CUSTÓDIA", "\$ 45.280.000",
            Icons.account_balance_wallet, Colors.white),
        _financeCard("LUCRO DISTRIBUÍDO", "\$ 3.150.000",
            Icons.payments_outlined, emerald),
        _financeCard("APORTES PENDENTES", "\$ 840.000", Icons.hourglass_top,
            Colors.orangeAccent),
      ],
    );
  }

  Widget _financeCard(
      String label, String value, IconData icon, Color valColor) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 30),
          const SizedBox(width: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(value,
                  style: GoogleFonts.cinzel(
                      color: valColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildGrowthChartSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("CRESCIMENTO PATRIMONIAL (YTD)",
                  style: GoogleFonts.cinzel(
                      color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
              const Text("JAN - DEZ 2026",
                  style: TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        const months = [
                          'JAN',
                          'MAR',
                          'MAI',
                          'JUL',
                          'SET',
                          'NOV'
                        ];
                        if (val % 2 == 0 && val < months.length * 2) {
                          return Text(months[(val / 2).toInt()],
                              style: const TextStyle(
                                  color: Colors.white24, fontSize: 10));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 30),
                      FlSpot(2, 35),
                      FlSpot(4, 32),
                      FlSpot(6, 40),
                      FlSpot(8, 45),
                      FlSpot(10, 42),
                      FlSpot(12, 50)
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData:
                        BarAreaData(show: true, color: gold.withOpacity(0.05)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return StreamBuilder<QuerySnapshot>(
      // Assume-se uma coleção 'transacoes' para este módulo
      stream: FirebaseFirestore.instance
          .collection('transacoes')
          .orderBy('data', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(15)),
            child: const Center(
                child: Text("Nenhuma transação registrada.",
                    style: TextStyle(color: Colors.white24))),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final tx =
                snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final bool isEntry = tx['tipo'] == 'aporte';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                leading: Icon(
                  isEntry
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: isEntry ? emerald : Colors.redAccent,
                ),
                title: Text(tx['descricao'] ?? "Transação SGT",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(tx['investidor'] ?? "Investidor Private",
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
                trailing: Text(
                  "${isEntry ? '+' : '-'} \$ ${tx['valor']}",
                  style: GoogleFonts.robotoMono(
                    color: isEntry ? emerald : Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
