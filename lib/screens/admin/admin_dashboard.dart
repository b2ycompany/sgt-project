import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgt_projeto/screens/admin/gestao_suporte_screen.dart';

// --- IMPORTAÇÕES ABSOLUTAS ---
import 'package:sgt_projeto/screens/admin/gestao_usuarios_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_investimentos_screen.dart';
import 'package:sgt_projeto/screens/admin/ranking_investidores_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';

/// COMMAND CENTER v5.5 - ABSOLUTE INTEGRITY & HIGH DENSITY
/// Terminal Administrativo para Gestão de Patrimônio e Ativos USA.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  // PALETA DE CORES INSTITUCIONAL
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color errorRed = const Color(0xFFC62828);

  // MOTOR DE MONITORAMENTO REAL-TIME (STREAMS)
  late StreamSubscription<QuerySnapshot> _userStream;
  late StreamSubscription<QuerySnapshot> _txStream;
  late StreamSubscription<QuerySnapshot> _complianceStream;

  // LOG DE AUDITORIA OPERACIONAL
  final List<Map<String, dynamic>> _internalActivityLog = [];

  @override
  void initState() {
    super.initState();
    // Inicia escuta ativa das coleções críticas do Firestore
    _launchRealTimeInfrastructure();
  }

  @override
  void dispose() {
    _userStream.cancel();
    _txStream.cancel();
    _complianceStream.cancel();
    super.dispose();
  }

  /// Conecta o Terminal Administrativo aos eventos de rede em tempo real
  void _launchRealTimeInfrastructure() {
    // 1. Ouvinte para Novos Leads (ex: Leonardo #9280)
    _userStream = FirebaseFirestore.instance
        .collection('usuarios')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _dispatchAlert(
              "LEAD DISCOVERY", "${data['nome']} aguarda qualificação.");
          _appendToLog("Lead", data['nome'], gold);
        }
      }
    });

    // 2. Ouvinte para Aportes Financeiros
    _txStream = FirebaseFirestore.instance
        .collection('transacoes')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _dispatchAlert(
              "APORTE DETECTADO", "Crédito de \$ ${data['valor']} em análise.");
          _appendToLog("Aporte", "\$ ${data['valor']}", emerald);
        }
      }
    });

    // 3. Ouvinte para Compliance e Termos
    _complianceStream = FirebaseFirestore.instance
        .collection('usuarios')
        .where('assinatura_digital_status', isEqualTo: 'confirmado')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          _appendToLog("Compliance", "Termo assinado: ${data['nome']}",
              Colors.blueAccent);
        }
      }
    });
  }

  void _dispatchAlert(String title, String body) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gold,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(25),
        duration: const Duration(seconds: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        content: Row(
          children: [
            const Icon(Icons.security_update_good,
                color: Color(0xFF050F22), size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF050F22),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text(body,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _appendToLog(String cat, String val, Color col) {
    setState(() {
      _internalActivityLog.insert(0, {
        "cat": cat,
        "val": val,
        "col": col,
        "time": DateTime.now(),
      });
      if (_internalActivityLog.length > 10) _internalActivityLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder: O motor de responsividade para Mobile e Notebook
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isMobile = constraints.maxWidth < 900;

        // Estilo Glassmorphism dinâmico
        final Color cardBg = isMobile
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.05);

        return Scaffold(
          backgroundColor: navy,
          drawer: _buildAdaptiveDrawer(isMobile),
          appBar: _buildAdaptiveAppBar(isMobile),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 25 : 60, vertical: isMobile ? 35 : 55),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExecutiveHeader(isMobile),
                const SizedBox(height: 50),

                // MÉTRICAS GLOBAIS
                _buildKPISection(isMobile, cardBg),
                const SizedBox(height: 60),

                // ANALYTICS ADAPTATIVO
                if (isMobile) ...[
                  _buildPerformanceChart(isMobile),
                  const SizedBox(height: 35),
                  _buildLiveFeed(isMobile, cardBg),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 3, child: _buildPerformanceChart(isMobile)),
                      const SizedBox(width: 40),
                      Expanded(
                          flex: 2, child: _buildLiveFeed(isMobile, cardBg)),
                    ],
                  ),

                const SizedBox(height: 70),

                // GRID OPERACIONAL
                Text("OPERATIONAL COMMAND HUB",
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: isMobile ? 15 : 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5)),
                const SizedBox(height: 35),
                _buildActionGrid(isMobile, cardBg),

                const SizedBox(height: 70),

                // WORKFLOW DISCOVERY
                _buildKYCSection(isMobile, cardBg),

                const SizedBox(height: 120),
                _buildComplianceFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- COMPONENTES DE INTERFACE DE ALTA PERFORMANCE ---

  PreferredSizeWidget _buildAdaptiveAppBar(bool isMobile) {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold, size: 28),
      title: Text(
        "CIG COMMAND CENTER",
        style: GoogleFonts.cinzel(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 4),
      ),
      actions: [
        _buildNotificationBadge(),
        const SizedBox(width: 25),
      ],
    );
  }

  Widget _buildExecutiveHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ENCRYPTED ASSET MONITORING • v5.5.2",
            style: TextStyle(
                color: gold.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 12),
        Text("PAINEL EXECUTIVO",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: isMobile ? 28 : 44,
                fontWeight: FontWeight.bold)),
        Container(
          margin: const EdgeInsets.only(top: 15),
          width: 100,
          height: 3,
          color: gold,
        ),
      ],
    );
  }

  Widget _buildKPISection(bool isMobile, Color cardBg) {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children: [
        _kpiCard("AUM (CAPITAL GESTÃO)", "\$ 45.28M", Icons.account_balance,
            Colors.white, isMobile, cardBg),
        _kpiCard("YIELD MÉDIO ATIVO", "24.8% a.a.", Icons.trending_up, emerald,
            isMobile, cardBg),
        _kpiCard("LANCES EXECUTADOS", "128 Lotes", Icons.gavel_rounded, gold,
            isMobile, cardBg),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color valColor,
      bool isMobile, Color bg) {
    double cardWidth =
        isMobile ? (MediaQuery.of(context).size.width - 80) / 2 : 340;

    if (isMobile && label.contains("LANCES"))
      cardWidth = MediaQuery.of(context).size.width - 50;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 30),
          const SizedBox(height: 25),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: valColor, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(45),
      height: 420,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ATIVIDADE DE LANCES (24H)",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(5, 6),
                      FlSpot(10, 4),
                      FlSpot(15, 11),
                      FlSpot(20, 15),
                      FlSpot(24, 12)
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: gold.withValues(alpha: 0.06)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveFeed(bool isMobile, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(40),
      height: 420,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: gold.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FEED DE ATIVIDADE",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 35),
          Expanded(
            child: _internalActivityLog.isEmpty
                ? const Center(
                    child: Text("Sincronizando canais...",
                        style: TextStyle(color: Colors.white12, fontSize: 10)))
                : ListView.builder(
                    itemCount: _internalActivityLog.length,
                    itemBuilder: (context, index) {
                      final log = _internalActivityLog[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Row(
                          children: [
                            Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    color: log['col'], shape: BoxShape.circle)),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${log['cat'].toUpperCase()}: ${log['val']}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "${log['time'].hour}:${log['time'].minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                          color: Colors.white24, fontSize: 9)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(bool isMobile, Color cardBg) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 5, // Aumentado para 5 colunas no Desktop
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      childAspectRatio: isMobile ? 1.0 : 1.2,
      children: [
        _actionCard("GESTÃO FINANCEIRA", "Dividendos", Icons.payments_outlined,
            const GestaoFinanceiraScreen(), cardBg),
        _actionCard("COMPLIANCE KYC", "Discovery", Icons.how_to_reg,
            const GestaoUsuariosScreen(), cardBg),
        _actionCard(
            "PORTFÓLIO USA",
            "Novas Ofertas",
            Icons.add_location_alt_outlined,
            const GestaoInvestimentosScreen(),
            cardBg),
        _actionCard(
            "CONCIERGE HUB",
            "Suporte Tickets",
            Icons.headset_mic_outlined,
            const GestaoSuporteScreen(),
            cardBg), // NOVO
        _actionCard("RANKING WHALES", "Elite Private", Icons.star_border,
            const RankingInvestidoresScreen(), cardBg),
      ],
    );
  }

  Widget _actionCard(
      String title, String sub, IconData icon, Widget screen, Color bg) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: gold, size: 30),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildKYCSection(bool isMobile, Color cardBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("APROVAÇÃO IMEDIATA (KYC DISCOVERY)",
            style: GoogleFonts.cinzel(
                color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 35),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .where('status', isEqualTo: 'pendente')
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return _buildEmptyLeadState();

            return Column(
              children: docs
                  .map((doc) => _buildApprovalListItem(doc, cardBg))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildApprovalListItem(DocumentSnapshot doc, Color cardBg) {
    final user = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: gold.withValues(alpha: 0.1),
          child: Text(user['numero_fila'] ?? "?",
              style: TextStyle(
                  color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        title: Text(user['nome'] ?? "Investidor",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        subtitle: Text(
            "Perfil: ${user['perfil_investidor']} • Fila: ${user['numero_fila']}",
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 28),
                onPressed: () => doc.reference.update({'status': 'aprovado'})),
            const SizedBox(width: 10),
            IconButton(
                icon: const Icon(Icons.highlight_off,
                    color: Colors.redAccent, size: 28),
                onPressed: () => doc.reference.update({'status': 'recusado'})),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyLeadState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(20)),
      child: const Center(
          child: Text("NENHUM INVESTIDOR AGUARDANDO NO MOMENTO.",
              style: TextStyle(
                  color: Colors.white12, fontSize: 11, letterSpacing: 2))),
    );
  }

  Widget _buildNotificationBadge() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('status', isEqualTo: 'pendente')
          .snapshots(),
      builder: (context, snap) {
        int count = snap.hasData ? snap.data!.docs.length : 0;
        return Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.notifications_none,
                color: Colors.white70, size: 30),
            if (count > 0)
              Positioned(
                top: 10,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: Colors.red, shape: BoxShape.circle),
                  child: Text("$count",
                      style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
              )
          ],
        );
      },
    );
  }

  Widget _buildAdaptiveDrawer(bool isMobile) {
    return Drawer(
      backgroundColor: navy,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: gold.withValues(alpha: 0.1)))),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance, color: gold, size: 50),
                  const SizedBox(height: 15),
                  Text("SGT ADMIN",
                      style: GoogleFonts.cinzel(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _drawerTile(Icons.dashboard, "Visão Geral", true),
                _drawerTile(
                    Icons.people_outline, "Gestão de Investidores", false),
                _drawerTile(Icons.landscape, "Portfólio USA", false),
                _drawerTile(Icons.analytics_outlined, "Análise de ROI", false),
                _drawerTile(
                    Icons.payments_outlined, "Dividendos e Aportes", false),
                _drawerTile(
                    Icons.security_outlined, "Logs de Compliance", false),
                const Divider(color: Colors.white10, height: 50),
                _drawerTile(
                    Icons.settings_outlined, "Parâmetros do Sistema", false),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("ENCERRAR SESSÃO",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, bool active) {
    return ListTile(
      leading: Icon(icon, color: active ? gold : Colors.white54, size: 22),
      title: Text(title,
          style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      onTap: () {},
    );
  }

  Widget _buildComplianceFooter() {
    return const Center(
      child: Column(
        children: [
          Text("CIG PRIVATE INVESTMENT GROUP • GLOBAL ASSET MANAGEMENT • 2026",
              style: TextStyle(
                  color: Colors.white10, fontSize: 9, letterSpacing: 2.5)),
          SizedBox(height: 15),
          Text("SECURED CONNECTION • ENCRYPTED DATA HUB",
              style: TextStyle(color: Colors.white10, fontSize: 8)),
        ],
      ),
    );
  }
}
