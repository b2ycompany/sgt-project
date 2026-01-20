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

/// Command Center v4.0.6 - Edição de Alta Visibilidade Mobile
/// Focado em garantir que ícones e métricas sejam legíveis em qualquer dispositivo.
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

  // Monitoramento de Eventos em Tempo Real
  late StreamSubscription<QuerySnapshot> _userSub;
  late StreamSubscription<QuerySnapshot> _txSub;
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
    super.dispose();
  }

  /// Configura os Listeners para capturar ações críticas do banco de dados
  void _initRealTimeEngine() {
    _userSub = FirebaseFirestore.instance
        .collection('usuarios')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _pushNotification(
              "NOVO INVESTIDOR", "${data['nome']} aguarda análise.");
          _logEvent("Lead", data['nome'], gold);
        }
      }
    });

    _txSub = FirebaseFirestore.instance
        .collection('transacoes')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _pushNotification("APORTE DECLARADO", "Valor: \$ ${data['valor']}");
          _logEvent("Aporte", "\$ ${data['valor']}", emerald);
        }
      }
    });
  }

  void _pushNotification(String title, String body) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gold,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Color(0xFF050F22)),
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

  void _logEvent(String cat, String val, Color col) {
    setState(() {
      _activityLog.insert(
          0, {"cat": cat, "val": val, "col": col, "time": DateTime.now()});
      if (_activityLog.length > 5) _activityLog.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Gatilho de responsividade para Mobile
      final bool isMobile = constraints.maxWidth < 850;

      // Definição de estilo de Card com alto contraste para mobile
      final Color cardBg = isMobile
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.05);

      return Scaffold(
        backgroundColor: navy,
        drawer: _buildAdaptiveDrawer(),
        appBar: _buildAdaptiveAppBar(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 20 : 50, vertical: isMobile ? 30 : 50),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isMobile),
              const SizedBox(height: 40),

              // --- SEÇÃO 1: KPIs ---
              _buildKPISection(isMobile, cardBg),
              const SizedBox(height: 50),

              // --- SEÇÃO 2: GRÁFICO E FEED ---
              if (isMobile) ...[
                _buildMainChart(isMobile),
                const SizedBox(height: 30),
                _buildActivityFeed(isMobile, cardBg),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: _buildMainChart(isMobile)),
                    const SizedBox(width: 30),
                    Expanded(
                        flex: 2, child: _buildActivityFeed(isMobile, cardBg)),
                  ],
                ),

              const SizedBox(height: 60),

              // --- SEÇÃO 3: GRID OPERACIONAL (2 COL MOBILE / 4 COL DESKTOP) ---
              Text("COMMAND: GESTÃO DE BACK-OFFICE",
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: isMobile ? 15 : 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 30),
              _buildActionGrid(isMobile, cardBg),

              const SizedBox(height: 60),

              // --- SEÇÃO 4: APROVAÇÃO RÁPIDA ---
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

  PreferredSizeWidget _buildAdaptiveAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold, size: 28),
      title: Text(
        "CIG COMMAND CENTER",
        style: GoogleFonts.cinzel(
            color: gold,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 3),
      ),
      actions: [
        _buildNotificationCounter(),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("ENCRYPTED MONITORING • 2026",
            style: TextStyle(
                color: gold.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 12),
        Text("DASHBOARD EXECUTIVO",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: isMobile ? 26 : 34,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildKPISection(bool isMobile, Color cardBg) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _kpiCard("AUM GLOBAL", "\$ 45.2M", Icons.account_balance, Colors.white,
            isMobile, cardBg),
        _kpiCard(
            "ROI MÉDIO", "24.8%", Icons.trending_up, emerald, isMobile, cardBg),
        _kpiCard("LANCES", "128", Icons.gavel_rounded, gold, isMobile, cardBg),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color,
      bool isMobile, Color cardBg) {
    double cardWidth =
        isMobile ? (MediaQuery.of(context).size.width - 60) / 2 : 320;

    if (isMobile && label == "LANCES")
      cardWidth = MediaQuery.of(context).size.width - 40;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: gold, size: 24),
          const SizedBox(height: 20),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMainChart(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(35),
      height: 380,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("RENDIMENTO POR ATIVO (24H)",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
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
                      FlSpot(0, 3),
                      FlSpot(5, 6),
                      FlSpot(10, 4),
                      FlSpot(15, 11),
                      FlSpot(20, 15)
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
      height: 380,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("FEED DE EVENTOS",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
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
                        padding: const EdgeInsets.only(bottom: 20),
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
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "${log['time'].hour}:${log['time'].minute}",
                                      style: const TextStyle(
                                          color: Colors.white24, fontSize: 8)),
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
      crossAxisCount: isMobile ? 2 : 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: isMobile ? 1.0 : 1.3,
      children: [
        _actionCard("GESTÃO FINANCEIRA", "Dividendos", Icons.payments_outlined,
            const GestaoFinanceiraScreen(), cardBg),
        _actionCard("COMPLIANCE KYC", "Discovery", Icons.verified_user_outlined,
            const GestaoUsuariosScreen(), cardBg),
        _actionCard(
            "PORTFÓLIO USA",
            "Novas Ofertas",
            Icons.add_location_alt_outlined,
            const GestaoInvestimentosScreen(),
            cardBg),
        _actionCard("RANKING WHALES", "Performance", Icons.star_border,
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
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: gold.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: gold.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: gold, size: 28),
            ),
            const SizedBox(height: 15),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
            const SizedBox(height: 5),
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
                color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
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
              return const Text("Sem leads pendentes.",
                  style: TextStyle(color: Colors.white10, fontSize: 11));
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
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
                fontSize: 14)),
        subtitle: Text(
            "Perfil: ${user['perfil_investidor']} • ${user['faixa_patrimonial']}",
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon:
                  const Icon(Icons.check_circle, color: Colors.green, size: 28),
              onPressed: () => doc.reference.update({'status': 'aprovado'}),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 28),
              onPressed: () => doc.reference.update({'status': 'recusado'}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCounter() {
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

  Widget _buildAdaptiveDrawer() {
    return Drawer(
      backgroundColor: navy,
      child: Column(
        children: [
          DrawerHeader(
              child: Center(
                  child: Icon(Icons.account_balance, color: gold, size: 60))),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Sair do Sistema",
                style: TextStyle(color: Colors.white)),
            onTap: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
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
          Text("SECURED CONNECTION • ENCRYPTED DATA",
              style: TextStyle(color: Colors.white10, fontSize: 7)),
        ],
      ),
    );
  }
}
