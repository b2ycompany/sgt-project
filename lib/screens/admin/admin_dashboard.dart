import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÃO DOS MÓDULOS DE ALTA PERFORMANCE ---
import 'package:sgt_projeto/screens/admin/gestao_usuarios_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_investimentos_screen.dart';
import 'package:sgt_projeto/screens/admin/ranking_investidores_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_financeira_screen.dart';

/// Centro de Comando Administrativo (Command Center) - Versão 2026.1
/// Focado em Gestão de Patrimônio e Aprovação de Compliance em Tempo Real.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  // Paleta de Luxo Private Banking
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color cardBg = Colors.white.withOpacity(0.03);

  // Controladores de Animação para Efeitos Visuais
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      drawer: _buildAdminDrawer(),
      appBar: _buildCustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExecutiveHeader(),
            const SizedBox(height: 45),

            // --- BLOCO 1: INDICADORES FINANCEIROS (KPIs) ---
            _buildFinancialOverview(),
            const SizedBox(height: 55),

            // --- BLOCO 2: GRADE OPERACIONAL DE GESTÃO ---
            Text(
              "GESTÃO OPERACIONAL DE ATIVOS",
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 25),
            _buildOperationalGrid(),
            const SizedBox(height: 55),

            // --- BLOCO 3: INTELIGÊNCIA DE MERCADO (GRÁFICO) ---
            _buildMarketIntelligenceSection(),
            const SizedBox(height: 55),

            // --- BLOCO 4: WORKFLOW DE APROVAÇÃO (1 CLIQUE) ---
            _buildApprovalWorkflowSection(),
            const SizedBox(height: 55),

            // --- BLOCO 5: LOGS DE AUDITORIA DO SISTEMA ---
            _buildSystemAuditSection(),
            const SizedBox(height: 40),

            _buildTechnicalFooter(),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DETALHADOS (SEM ABREVIAÇÕES) ---

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold, size: 28),
      title: Text(
        "CIG COMMAND CENTER",
        style: GoogleFonts.cinzel(
          color: gold,
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 3,
        ),
      ),
      centerTitle: true,
      actions: [
        _buildNotificationStreamIcon(),
        const SizedBox(width: 15),
        _buildAdminProfileCircle(),
        const SizedBox(width: 25),
      ],
    );
  }

  Widget _buildExecutiveHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Private Asset Management • 2026",
          style: TextStyle(
              color: gold.withOpacity(0.5),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 3),
        ),
        const SizedBox(height: 10),
        Text(
          "RELATÓRIO EXECUTIVO",
          style: GoogleFonts.cinzel(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 15),
          width: 80,
          height: 2,
          color: gold,
        ),
      ],
    );
  }

  Widget _buildFinancialOverview() {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      children: [
        _kpiCard("AUM (CAPITAL GESTÃO)", "\$ 45.280.000", Icons.account_balance,
            Colors.white),
        _kpiCard("LANCES EM CURSO", "128", Icons.gavel_rounded, gold),
        _kpiCard(
            "YIELD MÉDIO ENTREGUE", "24.8% a.a.", Icons.trending_up, emerald),
        _kpiCard("QUALIFICAÇÃO (FILA)", "14 Leads", Icons.how_to_reg,
            Colors.orangeAccent),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color valColor) {
    return Container(
      width: 330,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 35),
          const SizedBox(height: 25),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: valColor, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOperationalGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 1200
          ? 4
          : (MediaQuery.of(context).size.width > 700 ? 2 : 1),
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      childAspectRatio: 1.25,
      children: [
        _actionCard("GESTÃO FINANCEIRA", "Fluxo de Caixa e Balanço",
            Icons.attach_money, const GestaoFinanceiraScreen()),
        _actionCard("APROVAÇÕES KYC", "Compliance de Investidores",
            Icons.verified_user_outlined, const GestaoUsuariosScreen()),
        _actionCard("OFERTAS ATIVAS", "Lançamento de Terrenos",
            Icons.add_location_alt_outlined, const GestaoInvestimentosScreen()),
        _actionCard("RANKING WHALES", "Monitoramento de Grandes Capitais",
            Icons.leaderboard, const RankingInvestidoresScreen()),
      ],
    );
  }

  Widget _actionCard(String title, String sub, IconData icon, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: gold.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: gold, size: 40),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 10),
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
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("LANCES EM TEMPO REAL (ATIVIDADE 24H)",
                  style: GoogleFonts.cinzel(
                      color: gold,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const Icon(Icons.auto_graph, color: Colors.white24, size: 20),
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
                      getTitlesWidget: (val, meta) => Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text("${val.toInt()}h",
                            style: const TextStyle(
                                color: Colors.white24, fontSize: 10)),
                      ),
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
                      FlSpot(0, 4),
                      FlSpot(4, 6),
                      FlSpot(8, 5),
                      FlSpot(12, 11),
                      FlSpot(16, 9),
                      FlSpot(20, 16),
                      FlSpot(24, 13)
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData:
                        BarAreaData(show: true, color: gold.withOpacity(0.08)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalWorkflowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("QUALIFICAÇÃO DE NOVOS INVESTIDORES",
            style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 30),
        StreamBuilder<QuerySnapshot>(
          // Busca usuários identificados no Discovery (Onboarding)
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .where('status', isEqualTo: 'pendente')
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return _emptyApprovalState();

            return Column(
              children: docs.map((doc) => _buildApprovalListItem(doc)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildApprovalListItem(DocumentSnapshot doc) {
    final user = doc.data() as Map<String, dynamic>;
    final String uid = doc.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(25),
        leading: CircleAvatar(
          backgroundColor: gold.withOpacity(0.2),
          child: Text(user['numero_fila'] ?? "?",
              style: TextStyle(
                  color: gold, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        title: Text(user['nome'] ?? "Investidor Anônimo",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
                "PERFIL: ${user['perfil_investidor']} • CAPITAL: ${user['faixa_patrimonial']}",
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            Text("EMAIL: ${user['email']}",
                style: TextStyle(color: gold.withOpacity(0.5), fontSize: 10)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _approvalActionBtn(Icons.check_circle, Colors.green,
                () => _handleStatusUpdate(uid, 'aprovado')),
            const SizedBox(width: 10),
            _approvalActionBtn(Icons.cancel, Colors.redAccent,
                () => _handleStatusUpdate(uid, 'recusado')),
          ],
        ),
      ),
    );
  }

  Widget _approvalActionBtn(IconData icon, Color color, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Future<void> _handleStatusUpdate(String uid, String status) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'status': status,
        'data_aprovacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Erro ao atualizar investidor: $e");
    }
  }

  Widget _emptyApprovalState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.01),
          borderRadius: BorderRadius.circular(15)),
      child: const Center(
        child: Text("NENHUM INVESTIDOR AGUARDANDO DISCOVERY",
            style: TextStyle(
                color: Colors.white12, fontSize: 12, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildSystemAuditSection() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("LOGS DE AUDITORIA INTERNA",
              style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          const SizedBox(height: 20),
          _auditLogTile("DB Connection", "ESTABLISHED", emerald),
          _auditLogTile("Compliance Scan", "COMPLETE", gold),
          _auditLogTile("US Asset Link", "SYNCED", emerald),
        ],
      ),
    );
  }

  Widget _auditLogTile(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(status,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildNotificationStreamIcon() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('status', isEqualTo: 'pendente')
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none, color: Colors.white70),
            if (count > 0)
              Positioned(
                top: 12,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text("$count",
                      style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              )
          ],
        );
      },
    );
  }

  Widget _buildAdminProfileCircle() {
    return InkWell(
      onTap: () => FirebaseAuth.instance.signOut(),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: gold.withOpacity(0.1),
        child: Icon(Icons.admin_panel_settings, color: gold, size: 20),
      ),
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
      backgroundColor: navy,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(color: gold.withOpacity(0.1)))),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, color: gold, size: 50),
                  const SizedBox(height: 15),
                  Text("SGT ADMIN",
                      style: GoogleFonts.cinzel(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _drawerTile(Icons.dashboard, "Dashboard Global", true),
                _drawerTile(Icons.people, "Gestão de Investidores", false),
                _drawerTile(Icons.landscape, "Portfólio de Terrenos", false),
                _drawerTile(Icons.analytics, "Análise de ROI", false),
                _drawerTile(Icons.security, "Configurações KYC", false),
                const Divider(color: Colors.white10),
                _drawerTile(Icons.settings, "Parâmetros do Sistema", false),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(30.0),
            child: Text("SGT-CIG PRIVATE v3.9.5",
                style: TextStyle(
                    color: Colors.white10, fontSize: 10, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, bool active) {
    return ListTile(
      leading: Icon(icon, color: active ? gold : Colors.white54),
      title: Text(title,
          style: TextStyle(
              color: active ? Colors.white : Colors.white70, fontSize: 13)),
      onTap: () {},
    );
  }

  Widget _buildTechnicalFooter() {
    return const Center(
      child: Text(
        "ENCRYPTED ACCESS • CIG PRIVATE INVESTMENT GROUP • 2026",
        style: TextStyle(color: Colors.white10, fontSize: 8, letterSpacing: 2),
      ),
    );
  }
}
