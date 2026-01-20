import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- MÓDULOS DE GESTÃO ---
import 'package:sgt_projeto/screens/admin/gestao_usuarios_screen.dart';
import 'package:sgt_projeto/screens/admin/gestao_investimentos_screen.dart';
import 'package:sgt_projeto/screens/admin/ranking_investidores_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  // Paleta de Luxo Private Banking
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color cardBg = Colors.white.withOpacity(0.03);

  // --- MOTOR DE NOTIFICAÇÕES EM TEMPO REAL ---
  late StreamSubscription<QuerySnapshot> _leadsSubscription;
  late StreamSubscription<QuerySnapshot> _assinaturasSubscription;
  late StreamSubscription<QuerySnapshot> _aportesSubscription;
  final List<Map<String, dynamic>> _feedEventos = [];

  @override
  void initState() {
    super.initState();
    _iniciarMonitoramentoAtivo();
  }

  @override
  void dispose() {
    _leadsSubscription.cancel();
    _assinaturasSubscription.cancel();
    _aportesSubscription.cancel();
    super.dispose();
  }

  /// Inicia os Listeners para capturar eventos sem recarregar a tela.
  void _iniciarMonitoramentoAtivo() {
    // 1. Notificar novos Leads do Discovery
    _leadsSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _dispararAlertaVisual(
              "NOVO LEAD", "Investidor ${data['nome']} aguarda análise.");
          _registrarNoFeed("Lead Discovery", data['nome'], gold);
        }
      }
    });

    // 2. Notificar Assinaturas Digitais
    _assinaturasSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .where('assinatura_digital_status', isEqualTo: 'confirmado')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added ||
            change.type == DocumentChangeType.modified) {
          final data = change.doc.data() as Map<String, dynamic>;
          _dispararAlertaVisual(
              "CONTRATO ASSINADO", "${data['nome']} assinou o termo private.");
          _registrarNoFeed("Compliance", data['nome'], emerald);
        }
      }
    });

    // 3. Notificar Novos Aportes (Transações)
    _aportesSubscription = FirebaseFirestore.instance
        .collection('transacoes')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _dispararAlertaVisual(
              "APORTE DECLARADO", "Valor: \$ ${data['valor']} recebido.");
          _registrarNoFeed(
              "Financeiro", "\$ ${data['valor']}", Colors.blueAccent);
        }
      }
    });
  }

  void _dispararAlertaVisual(String titulo, String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gold,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(25),
        content: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.black),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text(msg,
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

  void _registrarNoFeed(String categoria, String detalhe, Color cor) {
    setState(() {
      _feedEventos.insert(0, {
        "categoria": categoria,
        "detalhe": detalhe,
        "cor": cor,
        "hora": DateTime.now()
      });
      if (_feedEventos.length > 6) _feedEventos.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      drawer: _buildAdminDrawer(),
      appBar: _buildEliteAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(45),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExecutiveWelcome(),
            const SizedBox(height: 50),

            // KPIs FINANCEIROS TOTAIS
            _buildKpiMetricsRow(),
            const SizedBox(height: 55),

            // GRÁFICO E FEED DE ATIVIDADE REAL-TIME
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildPerformanceAnalytics()),
                const SizedBox(width: 35),
                Expanded(flex: 2, child: _buildLiveActivityFeed()),
              ],
            ),
            const SizedBox(height: 55),

            // GRADE DE AÇÕES OPERACIONAIS
            Text("COMMAND: GESTÃO DE BACK-OFFICE",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildOperationalActionGrid(),
            const SizedBox(height: 60),

            // LISTA DE APROVAÇÃO RÁPIDA (KYC)
            _buildQuickKYCApprovalSection(),

            const SizedBox(height: 50),
            _buildTechnicalFooter(),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE UI (ALTA DENSIDADE) ---

  PreferredSizeWidget _buildEliteAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold, size: 28),
      title: Text("CIG COMMAND CENTER",
          style: GoogleFonts.cinzel(
              color: gold,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 3)),
      actions: [
        _buildNotificationStreamCounter(),
        const SizedBox(width: 20),
        IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white24),
            onPressed: () {}),
        const SizedBox(width: 30),
      ],
    );
  }

  Widget _buildExecutiveWelcome() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("REAL-TIME SYSTEM MONITORING • v4.0.2",
          style: TextStyle(
              color: gold.withOpacity(0.4),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 4)),
      const SizedBox(height: 12),
      Text("RELATÓRIO EXECUTIVO",
          style: GoogleFonts.cinzel(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
      Container(
          margin: const EdgeInsets.only(top: 15),
          width: 100,
          height: 2,
          color: gold),
    ]);
  }

  Widget _buildKpiMetricsRow() {
    return Wrap(
      spacing: 30,
      runSpacing: 30,
      children: [
        _kpiItem("TOTAL AUM (VALOR EM GESTÃO)", "\$ 45.28M",
            Icons.account_balance, Colors.white),
        _kpiItem(
            "ROI MÉDIO ENTREGUE", "24.8% a.a.", Icons.trending_up, emerald),
        _kpiItem("LANCES ATIVOS (USA)", "128 Lotes", Icons.gavel_rounded, gold),
      ],
    );
  }

  Widget _kpiItem(String l, String v, IconData i, Color c) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, color: gold, size: 30),
        const SizedBox(height: 25),
        Text(l,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        Text(v,
            style: GoogleFonts.cinzel(
                color: c, fontSize: 26, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildPerformanceAnalytics() {
    return Container(
      padding: const EdgeInsets.all(45),
      height: 420,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.02))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("VOLUMETRIA DE MERCADO (24H)",
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
                    FlSpot(4, 5),
                    FlSpot(8, 4),
                    FlSpot(12, 10),
                    FlSpot(16, 7),
                    FlSpot(20, 14)
                  ],
                  isCurved: true,
                  color: gold,
                  barWidth: 4,
                  dotData: const FlDotData(show: false),
                  belowBarData:
                      BarAreaData(show: true, color: gold.withOpacity(0.06)),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildLiveActivityFeed() {
    return Container(
      padding: const EdgeInsets.all(40),
      height: 420,
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withOpacity(0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("FEED DE ATIVIDADE",
            style: GoogleFonts.cinzel(
                color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 35),
        Expanded(
          child: _feedEventos.isEmpty
              ? const Center(
                  child: Text("Sincronizando eventos...",
                      style: TextStyle(color: Colors.white12, fontSize: 10)))
              : ListView.builder(
                  itemCount: _feedEventos.length,
                  itemBuilder: (context, index) {
                    final e = _feedEventos[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 25),
                      child: Row(children: [
                        Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                                color: e['cor'], shape: BoxShape.circle)),
                        const SizedBox(width: 20),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(
                                  "${e['categoria'].toUpperCase()}: ${e['detalhe']}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "${e['hora'].hour}:${e['hora'].minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                      color: Colors.white24, fontSize: 9)),
                            ])),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _buildOperationalActionGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 30,
      crossAxisSpacing: 30,
      childAspectRatio: 1.4,
      children: [
        _actionCard("GESTÃO FINANCEIRA", "Aportes e Dividendos",
            Icons.payments_outlined, const GestaoFinanceiraScreen()),
        _actionCard("COMPLIANCE KYC", "Leads e Contratos",
            Icons.verified_user_outlined, const GestaoUsuariosScreen()),
        _actionCard("PORTFÓLIO USA", "Novas Ofertas",
            Icons.add_location_alt_outlined, const GestaoInvestimentosScreen()),
        _actionCard("RANKING WHALES", "Performance Cliente", Icons.star_border,
            const RankingInvestidoresScreen()),
      ],
    );
  }

  Widget _actionCard(String t, String s, IconData i, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(i, color: gold, size: 38),
          const SizedBox(height: 20),
          Text(t,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
          Text(s,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ]),
      ),
    );
  }

  Widget _buildQuickKYCApprovalSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("APROVAÇÃO IMEDIATA (DISCOVERY)",
          style: GoogleFonts.cinzel(
              color: gold, fontSize: 14, fontWeight: FontWeight.bold)),
      const SizedBox(height: 30),
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
            return const Text("Nenhum lead aguardando no momento.",
                style: TextStyle(color: Colors.white10, fontSize: 11));

          return Column(
            children: docs.map((doc) {
              final user = doc.data() as Map<String, dynamic>;
              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: gold.withOpacity(0.1))),
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: gold.withOpacity(0.15),
                      child: Text(user['numero_fila'] ?? "?",
                          style: TextStyle(
                              color: gold,
                              fontSize: 12,
                              fontWeight: FontWeight.bold))),
                  title: Text(user['nome'] ?? "Investidor",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  subtitle: Text(
                      "Perfil: ${user['perfil_investidor']} • ${user['faixa_patrimonial']}",
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green),
                          onPressed: () =>
                              doc.reference.update({'status': 'aprovado'})),
                      IconButton(
                          icon:
                              const Icon(Icons.cancel, color: Colors.redAccent),
                          onPressed: () =>
                              doc.reference.update({'status': 'recusado'})),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ]);
  }

  Widget _buildNotificationStreamCounter() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .where('status', isEqualTo: 'pendente')
          .snapshots(),
      builder: (context, snapshot) {
        int count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        return Stack(alignment: Alignment.center, children: [
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
                            fontSize: 8, color: Colors.white)))),
        ]);
      },
    );
  }

  Widget _buildAdminDrawer() {
    return Drawer(
        backgroundColor: navy,
        child: Column(children: [
          DrawerHeader(
              child: Center(
                  child: Icon(Icons.account_balance, color: gold, size: 60))),
          _drawerTile(Icons.dashboard, "Geral", true),
          _drawerTile(Icons.people, "Investidores", false),
          _drawerTile(Icons.landscape, "Portfólio USA", false),
          const Spacer(),
          _drawerTile(Icons.logout, "Encerrar Sessão", false,
              onTap: () => FirebaseAuth.instance.signOut()),
          const SizedBox(height: 40),
        ]));
  }

  Widget _drawerTile(IconData i, String t, bool a, {VoidCallback? onTap}) {
    return ListTile(
        leading: Icon(i, color: a ? gold : Colors.white38),
        title:
            Text(t, style: TextStyle(color: a ? Colors.white : Colors.white70)),
        onTap: onTap);
  }

  Widget _buildTechnicalFooter() {
    return const Center(
        child: Text("SGT-CIG PRIVATE v4.0.2 • SECURED CONNECTION • 2026",
            style: TextStyle(
                color: Colors.white10, fontSize: 8, letterSpacing: 2)));
  }
}
