import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES DOS MÓDULOS ---
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
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  // Aumento da opacidade do card para evitar o efeito "escuro" no mobile
  final Color cardBg = Colors.white.withOpacity(0.06);

  late StreamSubscription<QuerySnapshot> _leadsSub;
  late StreamSubscription<QuerySnapshot> _txSub;
  final List<Map<String, dynamic>> _liveFeed = [];

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  @override
  void dispose() {
    _leadsSub.cancel();
    _txSub.cancel();
    super.dispose();
  }

  void _setupListeners() {
    _leadsSub = FirebaseFirestore.instance
        .collection('usuarios')
        .where('status', isEqualTo: 'pendente')
        .snapshots()
        .listen((snap) {
      for (var change in snap.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          _notify("NOVO LEAD", "${data['nome']} aguarda aprovação.");
          _addToFeed("Lead", data['nome'], gold);
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
          _notify("NOVO APORTE", "Valor de \$ ${data['valor']} detectado.");
          _addToFeed("Aporte", "\$ ${data['valor']}", emerald);
        }
      }
    });
  }

  void _notify(String title, String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: gold,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        content: Row(children: [
          const Icon(Icons.bolt, color: Colors.black),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                Text(msg,
                    style:
                        const TextStyle(color: Colors.black87, fontSize: 10)),
              ])),
        ]),
      ),
    );
  }

  void _addToFeed(String cat, String det, Color color) {
    setState(() {
      _liveFeed.insert(
          0, {"cat": cat, "det": det, "color": color, "time": DateTime.now()});
      if (_liveFeed.length > 5) _liveFeed.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      drawer: _buildDrawer(),
      appBar: _buildAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 800;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 20 : 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isMobile),
                const SizedBox(height: 40),
                _buildKPIs(isMobile),
                const SizedBox(height: 50),

                // --- SEÇÃO RESPONSIVA: GRÁFICO E FEED ---
                if (isMobile) ...[
                  _buildChart(isMobile),
                  const SizedBox(height: 30),
                  _buildFeed(isMobile),
                ] else
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(flex: 3, child: _buildChart(isMobile)),
                    const SizedBox(width: 30),
                    Expanded(flex: 2, child: _buildFeed(isMobile)),
                  ]),

                const SizedBox(height: 50),
                Text("COMMAND: GESTÃO DE BACK-OFFICE",
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: isMobile ? 14 : 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 25),

                // --- GRID RESPONSIVO: RESOLVE O PROBLEMA DOS ÍCONES ---
                _buildActionGrid(isMobile),

                const SizedBox(height: 50),
                _buildQuickApproval(isMobile),
                const SizedBox(height: 100),
                _buildFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
        _buildNotificationCounter(),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("REAL-TIME SYSTEM MONITORING • 2026",
          style: TextStyle(
              color: gold.withOpacity(0.4),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 4)),
      const SizedBox(height: 10),
      Text("DASHBOARD EXECUTIVO",
          style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold)),
    ]);
  }

  Widget _buildKPIs(bool isMobile) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _kpiCard("AUM TOTAL", "\$ 45.2M", Icons.account_balance, Colors.white,
            isMobile),
        _kpiCard("ROI MÉDIO", "24.8%", Icons.trending_up, emerald, isMobile),
        _kpiCard("LANCES", "128", Icons.gavel, gold, isMobile),
      ],
    );
  }

  Widget _kpiCard(String l, String v, IconData i, Color c, bool isMobile) {
    double width =
        isMobile ? (MediaQuery.of(context).size.width - 60) / 2 : 300;
    if (isMobile && l == "LANCES")
      width = MediaQuery.of(context).size.width - 40;

    return Container(
      width: width,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, color: gold, size: 24),
        const SizedBox(height: 15),
        Text(l,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.bold)),
        Text(v,
            style: GoogleFonts.cinzel(
                color: c, fontSize: 20, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildChart(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(30),
      height: 350,
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.02))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("ATIVIDADE 24H",
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
                    FlSpot(5, 5),
                    FlSpot(10, 4),
                    FlSpot(15, 10),
                    FlSpot(20, 14)
                  ],
                  isCurved: true,
                  color: gold,
                  barWidth: 3,
                  belowBarData:
                      BarAreaData(show: true, color: gold.withOpacity(0.05)),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildFeed(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(25),
      height: 350,
      decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: gold.withOpacity(0.1))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("FEED DE ATIVIDADE",
            style: GoogleFonts.cinzel(
                color: gold, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 25),
        Expanded(
          child: _liveFeed.isEmpty
              ? const Center(
                  child: Text("Sincronizando...",
                      style: TextStyle(color: Colors.white10, fontSize: 10)))
              : ListView.builder(
                  itemCount: _liveFeed.length,
                  itemBuilder: (context, index) {
                    final e = _liveFeed[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Row(children: [
                        Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                                color: e['color'], shape: BoxShape.circle)),
                        const SizedBox(width: 15),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text("${e['cat']}: ${e['det']}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                              Text("${e['time'].hour}:${e['time'].minute}",
                                  style: const TextStyle(
                                      color: Colors.white24, fontSize: 8)),
                            ])),
                      ]),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  // --- CORREÇÃO DO GRID PARA MOBILE ---
  Widget _buildActionGrid(bool isMobile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isMobile ? 2 : 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: isMobile ? 1.0 : 1.3,
      children: [
        _actionCard("GESTÃO FINANCEIRA", "Aportes", Icons.payments_outlined,
            const GestaoFinanceiraScreen()),
        _actionCard("COMPLIANCE KYC", "Leads", Icons.verified_user_outlined,
            const GestaoUsuariosScreen()),
        _actionCard("PORTFÓLIO USA", "Ofertas", Icons.add_location_alt_outlined,
            const GestaoInvestimentosScreen()),
        _actionCard("RANKING WHALES", "Performance", Icons.star_border,
            const RankingInvestidoresScreen()),
      ],
    );
  }

  Widget _actionCard(String t, String s, IconData i, Widget screen) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: gold.withOpacity(0.15)) // Borda mais visível no mobile
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ÍCONE FORÇADO COM COR DOURADA PARA NÃO FICAR ESCURO
            Icon(i, color: gold, size: 32),
            const SizedBox(height: 15),
            Text(t,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
            const SizedBox(height: 5),
            Text(s,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickApproval(bool isMobile) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                style: TextStyle(color: Colors.white10, fontSize: 10));
          return Column(
              children:
                  docs.map((doc) => _approvalTile(doc, isMobile)).toList());
        },
      ),
    ]);
  }

  Widget _approvalTile(DocumentSnapshot doc, bool isMobile) {
    final user = doc.data() as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration:
          BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(user['nome'] ?? "Investidor",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        subtitle: Text("Protocolo: #${user['numero_fila']}",
            style: const TextStyle(color: Colors.white38, fontSize: 10)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              icon:
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
              onPressed: () => doc.reference.update({'status': 'aprovado'})),
          IconButton(
              icon: const Icon(Icons.cancel, color: Colors.redAccent, size: 24),
              onPressed: () => doc.reference.update({'status': 'recusado'})),
        ]),
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

  Widget _buildDrawer() {
    return Drawer(
        backgroundColor: navy,
        child: Column(children: [
          DrawerHeader(
              child: Center(
                  child: Icon(Icons.account_balance, color: gold, size: 60))),
          ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text("Sair", style: TextStyle(color: Colors.white)),
              onTap: () => FirebaseAuth.instance.signOut()),
        ]));
  }

  Widget _buildFooter() {
    return const Center(
        child: Text("SGT-CIG PRIVATE v4.0.2 • 2026",
            style: TextStyle(
                color: Colors.white10, fontSize: 8, letterSpacing: 2)));
  }
}
