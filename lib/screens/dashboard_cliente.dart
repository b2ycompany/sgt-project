import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';

/// Portal do Investidor Private - Versão 2026.1
/// Exclusivo para membros com status 'aprovado'.
class DashboardCliente extends StatefulWidget {
  const DashboardCliente({super.key});

  @override
  State<DashboardCliente> createState() => _DashboardClienteState();
}

class _DashboardClienteState extends State<DashboardCliente>
    with SingleTickerProviderStateMixin {
  // Paleta de Luxo Private Banking
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color glassBg = Colors.white.withValues(alpha: 0.03);

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      drawer: _buildInvestorDrawer(),
      appBar: _buildPrivateAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: FadeTransition(
          opacity: _fadeController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInvestorWelcome(),
              const SizedBox(height: 45),

              // --- BLOCO 1: PATRIMÔNIO LÍQUIDO (TOTAL EQUITY) ---
              _buildEquityMasterCard(),
              const SizedBox(height: 50),

              // --- BLOCO 2: PERFORMANCE & ROI INDICATORS ---
              Text(
                "PERFORMANCE DO PORTFÓLIO",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 25),
              _buildPerformanceMetricsGrid(),
              const SizedBox(height: 55),

              // --- BLOCO 3: MEUS ATIVOS (TERRENOS EM CARTEIRA) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ATIVOS SOB GESTÃO",
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2),
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text("VER EXTRATO PDF",
                          style: TextStyle(color: gold, fontSize: 10))),
                ],
              ),
              const SizedBox(height: 20),
              _buildMyAssetsList(),
              const SizedBox(height: 55),

              // --- BLOCO 4: OPORTUNIDADES OFF-MARKET (OFERTAS) ---
              Text(
                "NOVAS OPORTUNIDADES USA",
                style: GoogleFonts.cinzel(
                    color: gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 25),
              _buildOpportunityCarousel(),

              const SizedBox(height: 60),
              _buildPrivateFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODOS DE CONSTRUÇÃO DE INTERFACE (SEM ABREVIAÇÕES) ---

  PreferredSizeWidget _buildPrivateAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold),
      title: Text(
        "CIG PRIVATE PORTAL",
        style: GoogleFonts.cinzel(
          color: gold,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 3,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white70),
          onPressed: () {},
        ),
        _buildAvatarCircle(),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildAvatarCircle() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: gold.withValues(alpha: 0.1),
            child: Icon(Icons.person_outline, color: gold, size: 20),
          ),
        );
      },
    );
  }

  Widget _buildInvestorWelcome() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        String nome = snapshot.hasData
            ? snapshot.data!['nome'].split(' ')[0]
            : "Investidor";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "BEM-VINDO AO GRUPO PRIVATE,",
              style: TextStyle(
                  color: gold.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4),
            ),
            const SizedBox(height: 10),
            Text(
              "SR. $nome",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEquityMasterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: gold.withValues(alpha: 0.1)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gold.withValues(alpha: 0.08), Colors.transparent],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "VALOR TOTAL DO PATRIMÔNIO",
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              Icon(Icons.verified, color: gold, size: 18),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              double capital = snapshot.hasData
                  ? (snapshot.data!['capital_investido'] ?? 0.0).toDouble()
                  : 0.0;
              return Text(
                "\$ ${capital.toStringAsFixed(2)}",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold),
              );
            },
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.trending_up, color: emerald, size: 16),
              const SizedBox(width: 8),
              Text(
                "+14.2% EM RELAÇÃO AO ÚLTIMO MÊS",
                style: TextStyle(
                    color: emerald, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetricsGrid() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _metricCard("ROI MÉDIO", "24.8% a.a.", Icons.show_chart, emerald),
        _metricCard("ATIVOS TOTAIS", "04 Lotes", Icons.landscape, Colors.white),
        _metricCard(
            "CASH BALANCE", "\$ 12.450", Icons.account_balance_wallet, gold),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(20),
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
                  fontSize: 8,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value,
              style: GoogleFonts.cinzel(
                  color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMyAssetsList() {
    return StreamBuilder<QuerySnapshot>(
      // Busca terrenos vinculados ao UID do investidor
      stream: FirebaseFirestore.instance
          .collection('terrenos_investidor')
          .where('investidor_uid',
              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyAssetsState();
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _assetCard(
              data['titulo'] ?? "Terreno USA",
              data['localizacao'] ?? "Florida",
              data['valor_atual'] ?? 0.0,
              data['status_obra'] ?? "Em Análise",
            );
          }).toList(),
        );
      },
    );
  }

  Widget _assetCard(String title, String loc, double val, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(Icons.location_on_outlined, color: gold),
        ),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        subtitle: Text(loc,
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text("\$ ${val.toStringAsFixed(2)}",
                style: GoogleFonts.robotoMono(
                    color: emerald, fontWeight: FontWeight.bold)),
            Text(status.toUpperCase(),
                style: TextStyle(
                    color: gold, fontSize: 8, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildOpportunityCarousel() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ofertas')
          .where('status', isEqualTo: 'ativo')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final oferta =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              return _opportunityCard(oferta);
            },
          ),
        );
      },
    );
  }

  Widget _opportunityCard(Map<String, dynamic> data) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: glassBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              data['imagem_url'] ??
                  "https://images.unsplash.com/photo-1500382017468-9049fed747ef",
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['titulo'] ?? "Lote Premium",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
                const SizedBox(height: 5),
                Text("ROI ESTIMADO: ${data['roi_estimado']}%",
                    style: TextStyle(
                        color: emerald,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    minimumSize: const Size(double.infinity, 40),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text("ANALISAR LANCE",
                      style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAssetsState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.01),
          borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Icon(Icons.landscape_outlined, color: Colors.white12, size: 40),
          const SizedBox(height: 15),
          const Text("VOCÊ AINDA NÃO POSSUI ATIVOS IMOBILIÁRIOS.",
              style: TextStyle(
                  color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(height: 10),
          Text("VEJA AS OFERTAS ABAIXO PARA COMEÇAR.",
              style:
                  TextStyle(color: gold.withValues(alpha: 0.3), fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildInvestorDrawer() {
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
                  Text("CIG PRIVATE",
                      style: GoogleFonts.cinzel(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          _drawerTile(Icons.dashboard_outlined, "Visão Geral", true),
          _drawerTile(Icons.pie_chart_outline, "Minha Performance", false),
          _drawerTile(Icons.history, "Histórico Financeiro", false),
          _drawerTile(Icons.description_outlined, "Contratos e Notas", false),
          _drawerTile(Icons.support_agent, "Consultor Exclusivo", false),
          const Spacer(),
          _drawerTile(Icons.logout, "Sair do Portal", false,
              onTap: () => FirebaseAuth.instance.signOut()),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title, bool active,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: active ? gold : Colors.white38),
      title: Text(title,
          style: TextStyle(
              color: active ? Colors.white : Colors.white70, fontSize: 13)),
      onTap: onTap,
    );
  }

  Widget _buildPrivateFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            "CIG PRIVATE INVESTMENT GROUP • USA ASSET MANAGEMENT",
            style:
                TextStyle(color: Colors.white10, fontSize: 8, letterSpacing: 2),
          ),
          SizedBox(height: 10),
          Text(
            "SECURED CONNECTION • 256-BIT ENCRYPTION",
            style:
                TextStyle(color: Colors.white10, fontSize: 7, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
