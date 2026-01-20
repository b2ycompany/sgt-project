import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importação rigorosa de todos os módulos de gestão
import 'package:sgt_projeto/screens/admin/gestao_usuarios_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_investimentos_screen.dart';
import 'package:sgt_projeto/screens/admin/ranking_investidores_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Paleta de Luxo Private Banking
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color cardColor = Colors.white.withValues(alpha: 0.05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      drawer: _buildAdminDrawer(),
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          "CIG COMMAND CENTER",
          style: GoogleFonts.cinzel(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        actions: [
          _buildNotificationIcon(),
          const SizedBox(width: 10),
          _buildProfileAvatar(),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 40),

            // BLCO 1: KPIs FINANCEIROS EM TEMPO REAL
            _buildGlobalMetricsSection(),
            const SizedBox(height: 50),

            // BLOCO 2: GESTÃO OPERACIONAL (CARDS DE AÇÃO)
            Text(
              "GESTÃO OPERACIONAL",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 25),
            _buildActionGrid(),
            const SizedBox(height: 50),

            // BLOCO 3: MONITORAMENTO DE LANCES E INVESTIMENTOS
            _buildMarketIntelligenceSection(),
            const SizedBox(height: 50),

            // BLOCO 4: FILA DE ESPERA RÁPIDA (PREVIEW)
            _buildQuickUserApprovalSection(),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE UI (SEM ABREVIAÇÕES) ---

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Painel Administrativo v3.5",
          style: TextStyle(
              color: gold.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2),
        ),
        const SizedBox(height: 8),
        Text(
          "CONTROLE DE ATIVOS USA",
          style: GoogleFonts.cinzel(
              color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('status', isEqualTo: 'pendente')
          .snapshots(),
      builder: (context, snapshot) {
        int pendentes = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
                icon:
                    const Icon(Icons.notifications_none, color: Colors.white70),
                onPressed: () {}),
            if (pendentes > 0)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text("$pendentes",
                      style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileAvatar() {
    return InkWell(
      onTap: () => FirebaseAuth.instance.signOut(),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: gold.withValues(alpha: 0.2),
        child: Icon(Icons.admin_panel_settings, color: gold, size: 20),
      ),
    );
  }

  Widget _buildGlobalMetricsSection() {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      children: [
        _kpiCard("AUM TOTAL (GESTÃO)", "\$ 45.280.000", Icons.account_balance,
            Colors.white),
        _kpiCard("LANCES ATIVOS", "128", Icons.gavel_rounded, gold),
        _kpiCard(
            "YIELD MÉDIO ENTREGUE", "24.8% a.a.", Icons.trending_up, emerald),
        _kpiCard("INVESTIDORES NA FILA", "14", Icons.people_outline,
            Colors.orangeAccent),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color valColor) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: gold, size: 28),
          ),
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
              const SizedBox(height: 5),
              Text(value,
                  style: GoogleFonts.cinzel(
                      color: valColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: 1.3,
      children: [
        _actionCard("Gestão de Usuários", "Aprovar acessos e KYC",
            Icons.how_to_reg, const GestaoUsuariosScreen()),
        _actionCard("Lançar Investimento", "Criar novas ofertas/lotes",
            Icons.add_business, const GestaoInvestimentosScreen()),
        _actionCard("Ranking de Whales", "Maiores investidores",
            Icons.leaderboard_outlined, const RankingInvestidoresScreen()),
        _actionCard(
            "Fluxo de Rateio",
            "Calcular dividendos",
            Icons.pie_chart_outline,
            const Scaffold(body: Center(child: Text("Em desenvolvimento")))),
      ],
    );
  }

  Widget _actionCard(String title, String sub, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: gold.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: gold, size: 35),
            const SizedBox(height: 15),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 5),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketIntelligenceSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("INTELLIGENCE: FLUXO DE LANCES",
                  style: GoogleFonts.cinzel(
                      color: gold, fontSize: 14, fontWeight: FontWeight.bold)),
              const Icon(Icons.refresh, color: Colors.white24, size: 16),
            ],
          ),
          const SizedBox(height: 50),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) => Text("${val.toInt()}h",
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 10)),
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
                      FlSpot(0, 3),
                      FlSpot(4, 5),
                      FlSpot(8, 4),
                      FlSpot(12, 9),
                      FlSpot(16, 7),
                      FlSpot(20, 11),
                      FlSpot(24, 14)
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 4,
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

  Widget _buildQuickUserApprovalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("APROVAÇÕES RÁPIDAS",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 25),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .where('status', isEqualTo: 'pendente')
              .limit(3)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty)
              return const Text("Nenhum investidor pendente.",
                  style: TextStyle(color: Colors.white24));

            return Column(
              children: docs.map((doc) {
                final user = doc.data() as Map<String, dynamic>;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(
                        backgroundColor: gold,
                        child: const Icon(Icons.person, color: Colors.black)),
                    title: Text(user['nome'] ?? "Sem nome",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("Protocolo: #${user['numero_fila']}",
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                    trailing: ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const GestaoUsuariosScreen())),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          padding: const EdgeInsets.all(10)),
                      child: const Text("ANALISAR",
                          style: TextStyle(fontSize: 10)),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: navy,
      child: Column(
        children: [
          DrawerHeader(
              child: Center(
                  child: Icon(Icons.account_balance, color: gold, size: 60))),
          _drawerTile(Icons.dashboard, "Geral", true),
          _drawerTile(Icons.people, "Investidores", false),
          _drawerTile(Icons.landscape, "Terrenos", false),
          _drawerTile(Icons.attach_money, "Relatórios Financeiros", false),
          _drawerTile(Icons.security, "Logs de Auditoria", false),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("SAIR",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, bool active) {
    return ListTile(
      leading: Icon(icon, color: active ? gold : Colors.white54),
      title: Text(title,
          style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      onTap: () {},
    );
  }
}
