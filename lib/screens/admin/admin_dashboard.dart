import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Importação dos módulos administrativos completos
import 'package:sgt_projeto/screens/admin/gestao_usuarios_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_investimentos_screen.dart';
import 'package:sgt_projeto/screens/admin/ranking_investidores_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_rateio_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  // Definição da Paleta de Luxo Institucional CIG
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      drawer: _buildAdminDrawer(context),
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("CIG COMMAND CENTER",
            style: GoogleFonts.cinzel(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 2,
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white70),
            onPressed: () {},
            tooltip: "Alertas de Sistema",
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: "Finalizar Sessão",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título de Secção Estratégica
            Text("OVERVIEW ESTRATÉGICO",
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                )),
            const SizedBox(height: 30),

            // Indicadores Chave de Performance (KPIs)
            _buildGlobalMetrics(),
            const SizedBox(height: 50),

            // Grade de Gestão e Controle de Ativos
            _buildActionGrid(context),
            const SizedBox(height: 50),

            // Painel de Monitorização de Lances em Tempo Real
            _buildRealTimeBiddingSection(),
          ],
        ),
      ),
    );
  }

  // Bloco de Métricas Globais (Cards com dados dinâmicos)
  Widget _buildGlobalMetrics() {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      children: [
        _kpiCard("AUM (CAPITAL GESTÃO)", "\$ 45.2M", Icons.account_balance,
            Colors.white),
        _kpiCard("LANCES ATIVOS", "128", Icons.gavel, gold),
        _kpiCard("MÁX. ROI ENTREGUE", "31.4%", Icons.trending_up, emerald),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color valColor) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 40),
          const SizedBox(width: 25),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
              Text(value,
                  style: GoogleFonts.cinzel(
                      color: valColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  // Grade de Operações Administrativas
  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1200
          ? 4
          : (MediaQuery.of(context).size.width > 700 ? 2 : 1),
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      childAspectRatio: 1.2,
      children: [
        _adminCard(context, "Gestão de Usuários", "Aprovação KYC/Compliance",
            Icons.how_to_reg, const GestaoUsuariosScreen()),
        _adminCard(context, "Nova Oferta", "Lançar Anúncios de Lotes",
            Icons.add_business, const GestaoInvestimentosScreen()),
        _adminCard(context, "Ranking Investidores", "Monitorar Perfis Whales",
            Icons.leaderboard, const RankingInvestidoresScreen()),
        _adminCard(context, "Rateios & Lucros", "Distribuição de Dividendos",
            Icons.pie_chart, const GestaoRateioScreen()),
      ],
    );
  }

  Widget _adminCard(BuildContext context, String title, String sub,
      IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: gold.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: gold, size: 45),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 8),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // Painel de Monitorização de Lances em Tempo Real
  Widget _buildRealTimeBiddingSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ATIVIDADE DE LANCES (24H)",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 4,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text("${value.toInt()}h",
                              style: const TextStyle(
                                  color: Colors.white24, fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(4, 5),
                      FlSpot(8, 4),
                      FlSpot(12, 8),
                      FlSpot(16, 7),
                      FlSpot(20, 12),
                      FlSpot(24, 15)
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: gold.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Menu Lateral Administrativo (Drawer)
  Widget _buildAdminDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: navy,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: gold.withValues(alpha: 0.1))),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, color: gold, size: 50),
                  const SizedBox(height: 10),
                  Text("CIG PRIVATE",
                      style: GoogleFonts.cinzel(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(Icons.dashboard, "Dashboard Central", true),
                _drawerTile(Icons.people, "Investidores Ativos", false),
                _drawerTile(Icons.landscape, "Portfólio de Ativos", false),
                _drawerTile(Icons.analytics, "Relatórios de ROI", false),
                _drawerTile(Icons.security, "Compliance & Segurança", false),
                const Divider(color: Colors.white10),
                _drawerTile(Icons.settings, "Parâmetros do Sistema", false),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("SGT v3.5.0 • 2026",
                style: TextStyle(color: Colors.white10, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, bool selected) {
    return ListTile(
      leading: Icon(icon, color: selected ? gold : Colors.white54),
      title: Text(title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          )),
      onTap: () {},
    );
  }
}
