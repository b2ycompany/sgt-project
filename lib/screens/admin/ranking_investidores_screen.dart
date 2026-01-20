import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class RankingInvestidoresScreen extends StatefulWidget {
  const RankingInvestidoresScreen({super.key});

  @override
  State<RankingInvestidoresScreen> createState() =>
      _RankingInvestidoresScreenState();
}

class _RankingInvestidoresScreenState extends State<RankingInvestidoresScreen> {
  // Paleta de Luxo CIG
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          "RANKING DE GRANDES FORTUNAS",
          style: GoogleFonts.cinzel(
            color: gold,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Ordena investidores pelo capital total (campo 'capital_investido' deve existir no Firestore)
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('cargo', isEqualTo: 'cliente')
            .orderBy('capital_investido', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Nenhum dado de investimento disponível.",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
              ),
            );
          }

          final investidores = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: investidores.length,
            itemBuilder: (context, index) {
              final data = investidores[index].data() as Map<String, dynamic>;
              final double capital =
                  (data['capital_investido'] ?? 0).toDouble();
              final String nome = data['nome'] ?? 'Investidor Sigiloso';

              // Define o Tier baseado na posição
              return _buildInvestorRow(index + 1, nome, capital);
            },
          );
        },
      ),
    );
  }

  Widget _buildInvestorRow(int posicao, String nome, double capital) {
    bool isTop3 = posicao <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isTop3
            ? gold.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop3
              ? gold.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: _buildPositionBadge(posicao),
        title: Text(
          nome.toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: isTop3 ? FontWeight.bold : FontWeight.normal,
            letterSpacing: 1,
          ),
        ),
        subtitle: Text(
          "CATEGORIA: ${_getTierName(capital)}",
          style: TextStyle(
              color: gold.withValues(alpha: 0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$ ${capital.toStringAsFixed(2)}",
              style: GoogleFonts.cinzel(
                color: emerald,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              "CAPITAL ALOCADO",
              style: TextStyle(color: Colors.white24, fontSize: 8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionBadge(int posicao) {
    Color badgeColor;
    if (posicao == 1) {
      badgeColor = gold;
    } else if (posicao == 2)
      badgeColor = const Color(0xFFC0C0C0); // Prata
    else if (posicao == 3)
      badgeColor = const Color(0xFFCD7F32); // Bronze
    else
      badgeColor = Colors.white24;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: badgeColor.withValues(alpha: 0.2),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Center(
        child: Text(
          "#$posicao",
          style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getTierName(double capital) {
    if (capital >= 1000000) return "WHALE (INSTITUCIONAL)";
    if (capital >= 500000) return "DIAMOND (ULTRA HIGH)";
    if (capital >= 100000) return "PLATINUM (HIGH NET)";
    return "GOLD (PRIVATE)";
  }
}
