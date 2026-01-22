import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES INTEGRAIS DOS MÓDULOS OPERACIONAIS ---
import 'package:sgt_projeto/screens/admin/gestao_usuarios_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_investimentos_screen.dart';
import 'package:sgt_projeto/screens/admin/ranking_investidores_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_suporte_screen.dart';

/// COMMAND CENTER v5.6 - OPERATIONAL INTEGRITY EDITION
/// Terminal Administrativo com Navegação Ativa e Monitoramento Multi-Ativos.
/// Responsividade validada para Mobile e Desktop.
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  // CONFIGURAÇÃO VISUAL PRIVATE BANKING
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color alertRed = const Color(0xFFC62828);

  // MOTOR DE SINCRONIZAÇÃO EM TEMPO REAL (FIRESTORE LISTENERS)
  late StreamSubscription<QuerySnapshot> _userSubscription;
  late StreamSubscription<QuerySnapshot> _transactionSubscription;
  late StreamSubscription<QuerySnapshot> _complianceSubscription;

  // LOG DE AUDITORIA INTERNA
  final List<Map<String, dynamic>> _activityLog = [];

  @override
  void initState() {
    super.initState();
    // Inicialização da infraestrutura de escuta ativa
    _startExecutiveMonitoring();
  }

  @override
  void dispose() {
    // Encerramento de streams para preservação de memória
    _userSubscription.cancel();
    _transactionSubscription.cancel();
    _complianceSubscription.cancel();
    super.dispose();
  }

  /// Monitoramento Global: Captura eventos de usuários, lances e assinaturas
  void _startExecutiveMonitoring() {
    // 1. Escuta para Novos Leads (Discovery)
    _userSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _notifyAdmin("NOVO LEAD DETECTADO", "${data['nome']} aguarda KYC.");
          _updateInternalFeed("Lead", data['nome'], gold);
        }
      }
    });

    // 2. Escuta para Transações e Aportes
    _transactionSubscription = FirebaseFirestore.instance
        .collection('transacoes')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _notifyAdmin("APORTE IDENTIFICADO",
              "Valor: \$ ${data['valor']} em auditoria.");
          _updateInternalFeed("Aporte", "\$ ${data['valor']}", emerald);
        }
      }
    });

    // 3. Escuta para Compliance (Assinaturas Digitais)
    _complianceSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .where('assinatura_digital_status', isEqualTo: 'confirmado')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          _updateInternalFeed("Compliance", "Termo assinado: ${data['nome']}",
              Colors.blueAccent);
        }
      }
    });
  }

  void _notifyAdmin(String title, String body) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gold,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(25),
        duration: const Duration(seconds: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        content: Row(
          children: [
            Icon(Icons.gavel_rounded, color: navy, size: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(body,
                      style: TextStyle(
                          color: navy.withValues(alpha: 0.8), fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateInternalFeed(String cat, String val, Color col) {
    setState(() {
      _activityLog.insert(0, {
        "category": cat,
        "detail": val,
        "color": col,
        "timestamp": DateTime.now(),
      });
      if (_activityLog.length > 10) _activityLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // GESTÃO DE RESPONSIVIDADE MASTER
        final bool isMobile = constraints.maxWidth < 900;
        final Color cardBg = isMobile
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white.withValues(alpha: 0.04);

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
                _buildWelcomeHeader(isMobile),
                const SizedBox(height: 50),

                // --- BLOCO 1: KPIs FINANCEIROS ---
                _buildFinanceKPIs(isMobile, cardBg),
                const SizedBox(height: 60),

                // --- BLOCO 2: DATA VISUALIZATION ---
                if (isMobile) ...[
                  _buildMarketChart(isMobile),
                  const SizedBox(height: 35),
                  _buildLiveActivityLog(isMobile, cardBg),
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildMarketChart(isMobile)),
                      const SizedBox(width: 40),
                      Expanded(
                          flex: 2,
                          child: _buildLiveActivityLog(isMobile, cardBg)),
                    ],
                  ),

                const SizedBox(height: 70),

                // --- BLOCO 3: HUB OPERACIONAL (GRID) ---
                _buildOperationalTitle(isMobile),
                const SizedBox(height: 35),
                _buildActionHubGrid(isMobile, cardBg),

                const SizedBox(height: 70),

                // --- BLOCO 4: KYC DISCOVERY ---
                _buildKYCApprovalList(isMobile, cardBg),

                const SizedBox(height: 120),
                _buildSystemFooter(),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- COMPONENTES DE UI DE ALTA DENSIDADE ---

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

  Widget _buildWelcomeHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ENCRYPTED ASSET MONITORING • 2026",
            style: TextStyle(
                color: gold.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 15),
        Text("RELATÓRIO EXECUTIVO",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: isMobile ? 28 : 44,
                fontWeight: FontWeight.bold)),
        Container(
          margin: const EdgeInsets.only(top: 15),
          width: 120,
          height: 4,
          color: gold,
        ),
      ],
    );
  }

  Widget _buildFinanceKPIs(bool isMobile, Color cardBg) {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children: [
        _kpiItem("AUM (CAPITAL GESTÃO)", "\$ 45.28M", Icons.account_balance,
            Colors.white, isMobile, cardBg),
        _kpiItem("ROI MÉDIO POR ATIVO", "24.8% a.a.", Icons.trending_up,
            emerald, isMobile, cardBg),
        _kpiItem("ATIVOS NO PORTFÓLIO", "128 Unid.", Icons.layers_outlined,
            gold, isMobile, cardBg),
      ],
    );
  }

  Widget _kpiItem(String label, String value, IconData icon, Color valColor,
      bool isMobile, Color bg) {
    double width =
        isMobile ? (MediaQuery.of(context).size.width - 80) / 2 : 350;

    if (isMobile && label.contains("ATIVOS"))
      width = MediaQuery.of(context).size.width - 50;

    return Container(
      width: width,
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: gold, size: 26),
          ),
          const SizedBox(height: 30),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: valColor, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMarketChart(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(45),
      height: 450,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("TRAÇÃO DE MERCADO (LANCES 24H)",
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
                      FlSpot(0, 4),
                      FlSpot(5, 7),
                      FlSpot(10, 5),
                      FlSpot(15, 12),
                      FlSpot(20, 18),
                      FlSpot(25, 14)
                    ],
                    isCurved: true,
                    color: gold,
                    barWidth: 5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true, color: gold.withValues(alpha: 0.08)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveActivityLog(bool isMobile, Color cardBg) {
    return Container(
      padding: const EdgeInsets.all(40),
      height: 450,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: gold.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("AUDITORIA REAL-TIME",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 35),
          Expanded(
            child: _activityLog.isEmpty
                ? const Center(
                    child: Text("Sincronizando...",
                        style: TextStyle(color: Colors.white12, fontSize: 11)))
                : ListView.builder(
                    itemCount: _activityLog.length,
                    itemBuilder: (context, index) {
                      final log = _activityLog[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 25),
                        child: Row(
                          children: [
                            Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: log['color'],
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      "${log['category'].toUpperCase()}: ${log['detail']}",
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "${log['timestamp'].hour}:${log['timestamp'].minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                          color: Colors.white24, fontSize: 10)),
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

  Widget _buildOperationalTitle(bool isMobile) {
    return Text("OPERATIONAL HUB: ASSET MANAGEMENT",
        style: GoogleFonts.cinzel(
            color: Colors.white,
            fontSize: isMobile ? 16 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5));
  }

  Widget _buildActionHubGrid(bool isMobile, Color cardBg) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      mainAxisSpacing: 35,
      crossAxisSpacing: 35,
      childAspectRatio: isMobile ? 1.0 : 1.3,
      children: [
        _actionItem("Gestão Financeira", "Dividendos", Icons.payments_outlined,
            const GestaoFinanceiraScreen(), cardBg),
        _actionItem("Compliance KYC", "Discovery", Icons.how_to_reg,
            const GestaoUsuariosScreen(), cardBg),
        _actionItem(
            "Lançar Ativos",
            "Ofertas USA",
            Icons.add_location_alt_outlined,
            const GestaoInvestimentosScreen(),
            cardBg),
        _actionItem("Concierge Hub", "Suporte Tickets",
            Icons.headset_mic_outlined, const GestaoSuporteScreen(), cardBg),
      ],
    );
  }

  Widget _actionItem(
      String title, String sub, IconData icon, Widget screen, Color bg) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: gold, size: 32),
            ),
            const SizedBox(height: 22),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildKYCApprovalList(bool isMobile, Color cardBg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("KYC DISCOVERY: APROVAÇÃO IMEDIATA",
            style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 40),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('usuarios')
              .where('status', isEqualTo: 'pendente')
              .limit(5)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) return _emptyLeadVisual();

            return Column(
              children:
                  docs.map((doc) => _leadApprovalTile(doc, cardBg)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _leadApprovalTile(DocumentSnapshot doc, Color cardBg) {
    final user = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: gold.withValues(alpha: 0.1),
          child: Text(user['numero_fila'] ?? "?",
              style: TextStyle(
                  color: gold, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        title: Text(user['nome'] ?? "Investidor",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        subtitle: Text(
            "Perfil: ${user['perfil_investidor']} • Protocolo: ${user['numero_fila']}",
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 34),
                onPressed: () => doc.reference.update({'status': 'aprovado'})),
            const SizedBox(width: 15),
            IconButton(
                icon: const Icon(Icons.highlight_off,
                    color: Colors.redAccent, size: 34),
                onPressed: () => doc.reference.update({'status': 'recusado'})),
          ],
        ),
      ),
    );
  }

  Widget _emptyLeadVisual() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(60),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(25)),
      child: const Center(
          child: Text("NENHUM LEAD AGUARDANDO NO MOMENTO.",
              style: TextStyle(
                  color: Colors.white10, fontSize: 13, letterSpacing: 3))),
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

  // --- DRAWER INTEGRAL COM LINKS ATIVOS ---
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
                  Icon(Icons.account_balance, color: gold, size: 60),
                  const SizedBox(height: 15),
                  Text("SGT PRIVATE ADMIN",
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
                _drawerTile(Icons.dashboard, "Visão Geral", true,
                    () => Navigator.pop(context)),
                _drawerTile(
                    Icons.people_outline,
                    "Gestão de Investidores",
                    false,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const GestaoUsuariosScreen()))),
                _drawerTile(
                    Icons.landscape,
                    "Portfólio USA",
                    false,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const GestaoInvestimentosScreen()))),
                _drawerTile(
                    Icons.analytics_outlined,
                    "Ranking Whales",
                    false,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RankingInvestidoresScreen()))),
                _drawerTile(
                    Icons.payments_outlined,
                    "Dividendos e Aportes",
                    false,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const GestaoFinanceiraScreen()))),
                _drawerTile(
                    Icons.headset_mic_outlined,
                    "Concierge Hub",
                    false,
                    () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const GestaoSuporteScreen()))),
                const Divider(color: Colors.white10, height: 50),
                _drawerTile(Icons.settings_outlined, "Parâmetros do Sistema",
                    false, () {}),
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

  Widget _drawerTile(
      IconData icon, String title, bool active, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: active ? gold : Colors.white54, size: 22),
      title: Text(title,
          style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 13,
              fontWeight: active ? FontWeight.bold : FontWeight.normal)),
      onTap: onTap,
    );
  }

  Widget _buildSystemFooter() {
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
