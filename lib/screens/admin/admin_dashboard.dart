import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES DOS MÓDULOS OPERACIONAIS ---
import 'package:sgt_projeto/screens/admin/gestao_usuarios_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_investimentos_screen.dart';
import 'package:sgt_projeto/screens/admin/ranking_investidores_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';

/// Command Center v4.1.0 - Full Feature & Responsive Edition
/// Integra Monitoramento de Ativos, Gestão de Leads e Auditoria em Tempo Real.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  // Paleta de Luxo CIG Private
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color alertRed = const Color(0xFFC62828);

  // Monitoramento de Eventos em Tempo Real
  late StreamSubscription<QuerySnapshot> _userSub;
  late StreamSubscription<QuerySnapshot> _txSub;
  late StreamSubscription<QuerySnapshot> _signatureSub;
  final List<Map<String, dynamic>> _activityLog = [];

  @override
  void initState() {
    super.initState();
    _initRealTimeEngine();
  }

  @override
  void dispose() {
    _userSub.cancel();
    _txSub.cancel();
    _signatureSub.cancel();
    super.dispose();
  }

  /// Motor de Inteligência: Captura novos eventos sem refresh
  void _initRealTimeEngine() {
    // 1. Ouvinte para Novos Leads (Discovery)
    _userSub = FirebaseFirestore.instance
        .collection('usuarios')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _pushAlert(
              "NOVO LEAD DETECTADO", "Investidor ${data['nome']} aguarda KYC.");
          _logToFeed("Lead", data['nome'], gold);
        }
      }
    });

    // 2. Ouvinte para Novos Aportes (Finanças)
    _txSub = FirebaseFirestore.instance
        .collection('transacoes')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _pushAlert("SOLICITAÇÃO DE APORTE",
              "Valor de \$ ${data['valor']} para auditoria.");
          _logToFeed("Aporte", "\$ ${data['valor']}", emerald);
        }
      }
    });

    // 3. Ouvinte para Assinaturas de Contrato (Compliance)
    _signatureSub = FirebaseFirestore.instance
        .collection('usuarios')
        .where('assinatura_digital_status', isEqualTo: 'confirmado')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          _logToFeed("Compliance", "Termo assinado por ${data['nome']}",
              Colors.blueAccent);
        }
      }
    });
  }

  void _pushAlert(String title, String body) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gold,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        content: Row(
          children: [
            const Icon(Icons.security_update_good, color: Color(0xFF050F22)),
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

  void _logToFeed(String cat, String val, Color col) {
    setState(() {
      _activityLog.insert(
          0, {"cat": cat, "val": val, "col": col, "time": DateTime.now()});
      if (_activityLog.length > 7) _activityLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Lógica de Responsividade Crítica
      final bool isMobile = constraints.maxWidth < 850;
      final Color cardBg = isMobile
          ? Colors.white.withValues(alpha: 0.12) // Maior contraste no mobile
          : Colors.white.withValues(alpha: 0.05);

      return Scaffold(
        backgroundColor: navy,
        drawer: _buildAdaptiveDrawer(isMobile),
        appBar: _buildAdaptiveAppBar(isMobile),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 25 : 60, vertical: isMobile ? 30 : 50),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 45),

              // --- KPIs: FINANCEIRO E OPERACIONAL ---
              _buildKPISection(isMobile, cardBg),
              const SizedBox(height: 55),

              // --- ANALYTICS: GRÁFICO E FEED (LADO A LADO OU PILHA) ---
              if (isMobile) ...[
                _buildMainChart(isMobile),
                const SizedBox(height: 30),
                _buildActivityFeed(isMobile, cardBg),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildMainChart(isMobile)),
                    const SizedBox(width: 35),
                    Expanded(
                        flex: 2, child: _buildActivityFeed(isMobile, cardBg)),
                  ],
                ),

              const SizedBox(height: 65),

              // --- GRID DE GESTÃO: RESOLVE O PROBLEMA DOS ÍCONES ---
              Text("COMMAND: GESTÃO DE BACK-OFFICE",
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: isMobile ? 15 : 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 30),
              _buildActionGrid(isMobile, cardBg),

              const SizedBox(height: 65),

              // --- WORKFLOW: APROVAÇÃO RÁPIDA (LEONARDO FILA 9280) ---
              _buildApprovalSection(isMobile, cardBg),

              const SizedBox(height: 100),
              _buildSystemFooter(),
            ],
          ),
        ),
      );
    });
  }

  // --- COMPONENTES DE UI ---

  PreferredSizeWidget _buildAdaptiveAppBar(bool isMobile) {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold, size: 26),
      title: Text(
        "CIG COMMAND CENTER",
        style: GoogleFonts.cinzel(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 4),
      ),
      actions: [
        _buildNotificationStreamIcon(),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ENCRYPTED ASSET MONITORING • 2026",
            style: TextStyle(
                color: gold.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 12),
        Text("DASHBOARD EXECUTIVO",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: isMobile ? 26 : 38,
                fontWeight: FontWeight.bold)),
        Container(
          margin: const EdgeInsets.only(top: 15),
          width: 80,
          height: 3,
          color: gold,
        ),
      ],
    );
  }

  Widget _buildKPISection(bool isMobile, Color cardBg) {
    return Wrap(
      spacing: 25,
      runSpacing: 25,
      children: [
        _kpiCard("AUM (CAPITAL GESTÃO)", "\$ 45.28M", Icons.account_balance,
            Colors.white, isMobile, cardBg),
        _kpiCard("YIELD MÉDIO ENTREGUE", "24.8% a.a.", Icons.trending_up,
            emerald, isMobile, cardBg),
        _kpiCard("LANCES EXECUTADOS", "128 Lotes", Icons.gavel_rounded, gold,
            isMobile, cardBg),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color,
      bool isMobile, Color cardBg) {
    double cardWidth =
        isMobile ? (MediaQuery.of(context).size.width - 75) / 2 : 330;

    if (isMobile && label.contains("LANCES"))
      cardWidth = MediaQuery.of(context).size.width - 50;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 28),
          const SizedBox(height: 25),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 5),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMainChart(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(40),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ATIVIDADE DE LANCES (24H)",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 45),
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

  Widget _buildActivityFeed(bool isMobile, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(35),
      height: 400,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: gold.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FEED DE ATIVIDADE",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 35),
          Expanded(
            child: _activityLog.isEmpty
                ? const Center(
                    child: Text("Sincronizando...",
                        style: TextStyle(color: Colors.white12, fontSize: 10)))
                : ListView.builder(
                    itemCount: _activityLog.length,
                    itemBuilder: (context, index) {
                      final log = _activityLog[index];
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
                                      "${log['time'].hour}:${log['time'].minute}",
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

  // --- GRID DE AÇÕES COM CORREÇÃO DE VISIBILIDADE MOBILE ---
  Widget _buildActionGrid(bool isMobile, Color cardBg) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      mainAxisSpacing: 25,
      crossAxisSpacing: 25,
      childAspectRatio: isMobile ? 1.0 : 1.4,
      children: [
        _actionCard("GESTÃO FINANCEIRA", "Aportes e Saídas",
            Icons.payments_outlined, const GestaoFinanceiraScreen(), cardBg),
        _actionCard("COMPLIANCE KYC", "Leads e Discovery", Icons.how_to_reg,
            const GestaoUsuariosScreen(), cardBg),
        _actionCard(
            "PORTFÓLIO USA",
            "Lotes Disponíveis",
            Icons.add_location_alt_outlined,
            const GestaoInvestimentosScreen(),
            cardBg),
        _actionCard("RANKING WHALES", "Performance Cliente", Icons.star_border,
            const RankingInvestidoresScreen(), cardBg),
      ],
    );
  }

  Widget _actionCard(String title, String subtitle, IconData icon,
      Widget screen, Color cardBg) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Círculo de Destaque para Garantir que o ícone apareça
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: gold, size: 30),
            ),
            const SizedBox(height: 18),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalSection(bool isMobile, Color cardBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("APROVAÇÃO IMEDIATA (DISCOVERY)",
            style: GoogleFonts.cinzel(
                color: gold, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .where('status', isEqualTo: 'pendente')
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return _emptyLeadState();

            return Column(
              children:
                  docs.map((doc) => _approvalListItem(doc, cardBg)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _approvalListItem(DocumentSnapshot doc, Color cardBg) {
    final user = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
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
                fontSize: 15)),
        subtitle: Text(
            "Perfil: ${user['perfil_investidor']} • Fila: ${user['numero_fila']}", // Sincronizado com print
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 28),
              onPressed: () => _updateStatus(doc.id, 'aprovado'),
            ),
            IconButton(
              icon: const Icon(Icons.highlight_off,
                  color: Colors.redAccent, size: 28),
              onPressed: () => _updateStatus(doc.id, 'recusado'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(String uid, String status) async {
    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update({'status': status});
  }

  Widget _emptyLeadState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(15)),
      child: const Center(
          child: Text("NENHUM INVESTIDOR AGUARDANDO NO MOMENTO.",
              style: TextStyle(
                  color: Colors.white12, fontSize: 11, letterSpacing: 2))),
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

  // --- DRAWER INTEGRAL COM TODAS AS FUNCIONALIDADES SOLICITADAS ---
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
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _drawerTile(Icons.dashboard, "Visão Geral", true),
                _drawerTile(
                    Icons.people_outline, "Gestão de Investidores", false),
                _drawerTile(Icons.landscape, "Portfólio de Terrenos", false),
                _drawerTile(Icons.analytics_outlined, "Análise de ROI", false),
                _drawerTile(
                    Icons.payments_outlined, "Dividendos e Aportes", false),
                _drawerTile(
                    Icons.security_outlined, "Logs de Compliance", false),
                const Divider(color: Colors.white10),
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
                    fontSize: 12)),
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
              color: active ? Colors.white : Colors.white70, fontSize: 13)),
      onTap: () {},
    );
  }

  Widget _buildSystemFooter() {
    return const Center(
      child: Column(
        children: [
          Text("CIG PRIVATE INVESTMENT GROUP • 2026",
              style: TextStyle(
                  color: Colors.white10, fontSize: 8, letterSpacing: 2)),
          SizedBox(height: 10),
          Text("SECURED CONNECTION • ENCRYPTED DATA CHANNEL",
              style: TextStyle(color: Colors.white10, fontSize: 7)),
        ],
      ),
    );
  }
}
