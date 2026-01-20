import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

/// Módulo de Custódia Documental CIG Private
/// Permite a visualização e gestão de contratos, termos de adesão e K-1 Tax Forms.
class VisualizacaoDocumentosScreen extends StatefulWidget {
  const VisualizacaoDocumentosScreen({super.key});

  @override
  State<VisualizacaoDocumentosScreen> createState() =>
      _VisualizacaoDocumentosScreenState();
}

class _VisualizacaoDocumentosScreenState
    extends State<VisualizacaoDocumentosScreen> {
  // Definições de Estética Institucional
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: _buildPrivateAppBar(),
      body: Stack(
        children: [
          _buildBackgroundAura(),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                const SizedBox(height: 50),

                // --- SEÇÃO 1: DOCUMENTOS DE COMPLIANCE (OBRIGATÓRIOS) ---
                _buildSectionTitle("GOVERNANÇA E COMPLIANCE"),
                const SizedBox(height: 25),
                _buildComplianceDocsStream(),
                const SizedBox(height: 50),

                // --- SEÇÃO 2: CERTIFICADOS DE ATIVOS (REAL ESTATE) ---
                _buildSectionTitle("CERTIFICADOS DE PARTICIPAÇÃO"),
                const SizedBox(height: 25),
                _buildAssetDocsStream(),
                const SizedBox(height: 50),

                // --- SEÇÃO 3: RELATÓRIOS TRIBUTÁRIOS E K-1 ---
                _buildSectionTitle("DEMONSTRATIVOS FISCAIS USA"),
                const SizedBox(height: 25),
                _buildTaxDocsSection(),

                const SizedBox(height: 70),
                _buildLegalFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENTES DE INTERFACE (ALTA DENSIDADE) ---

  PreferredSizeWidget _buildPrivateAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold),
      title: Text("SECURE REPOSITORY",
          style: GoogleFonts.cinzel(
              color: gold,
              fontSize: 12,
              letterSpacing: 3,
              fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }

  Widget _buildBackgroundAura() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: gold.withOpacity(0.03),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(color: Colors.transparent),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CIG PRIVATE VAULT",
            style: GoogleFonts.poppins(
                color: gold.withOpacity(0.5),
                fontSize: 9,
                letterSpacing: 4,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("MEUS DOCUMENTOS",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text(
          "Acesse aqui todos os seus contratos assinados digitalmente, certificados de titularidade e relatórios K-1 para declaração fiscal.",
          style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 20, height: 1, color: gold),
        const SizedBox(width: 15),
        Text(title,
            style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildComplianceDocsStream() {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final bool assinouTermo = data['assinatura_digital_status'] ==
            'confirmado'; // Sincronizado com o módulo anterior

        return Column(
          children: [
            _documentTile(
              "Termo de Adesão ao Grupo Private",
              assinouTermo
                  ? "ASSINADO EM: ${_dateFormat.format((data['data_assinatura'] as Timestamp).toDate())}"
                  : "PENDENTE DE ASSINATURA",
              assinouTermo ? Icons.verified_user : Icons.pending_actions,
              assinouTermo ? emerald : Colors.orangeAccent,
              assinouTermo,
            ),
            const SizedBox(height: 15),
            _documentTile(
              "Política de Privacidade e Anti-Lavagem de Dinheiro (AML)",
              "VIGENTE - VERSÃO 2026.1",
              Icons.gavel_rounded,
              gold,
              true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildAssetDocsStream() {
    final user = FirebaseAuth.instance.currentUser;
    return StreamBuilder<QuerySnapshot>(
      // Busca documentos de ativos vinculados ao investidor
      stream: FirebaseFirestore.instance
          .collection('documentos_ativos')
          .where('investidor_uid', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyState(
              "Nenhum certificado de ativo emitido até o momento.");
        }

        return Column(
          children: docs.map((doc) {
            final docData = doc.data() as Map<String, dynamic>;
            return _documentTile(
              docData['titulo'] ?? "Certificado de Participação",
              "LOTE: ${docData['lote_id']} • EMITIDO EM: ${_dateFormat.format((docData['data_emissao'] as Timestamp).toDate())}",
              Icons.landscape_rounded,
              gold,
              true,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildTaxDocsSection() {
    return Column(
      children: [
        _documentTile(
          "Informe de Rendimentos Anual (K-1 Form)",
          "DISPONÍVEL EM MARÇO/2026",
          Icons.analytics_outlined,
          Colors.white24,
          false,
        ),
      ],
    );
  }

  Widget _documentTile(String title, String subtitle, IconData icon,
      Color statusColor, bool available) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        leading: Icon(icon, color: statusColor, size: 28),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(subtitle,
              style: TextStyle(
                  color: statusColor.withOpacity(0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ),
        trailing: available
            ? Icon(Icons.arrow_forward_ios, color: gold, size: 14)
            : Icon(Icons.lock_outline, color: Colors.white10, size: 16),
        onTap: available ? () => _abrirDocumento(title) : null,
      ),
    );
  }

  void _abrirDocumento(String docName) {
    // Simulação de abertura de PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Acessando cofre seguro para: $docName"),
        backgroundColor: gold,
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined, color: Colors.white10, size: 40),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalFooter() {
    return const Center(
      child: Column(
        children: [
          Text(
            "ESTES DOCUMENTOS POSSUEM VALIDADE JURÍDICA SOB A LEI AMERICANA (E-SIGN ACT)",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white10, fontSize: 8, letterSpacing: 1.5),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.security, color: Colors.white10, size: 12),
              SizedBox(width: 10),
              Text(
                "ENCRYPTED STORAGE",
                style: TextStyle(
                    color: Colors.white10,
                    fontSize: 8,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
