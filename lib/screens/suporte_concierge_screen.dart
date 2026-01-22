import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Private Concierge v1.0 - Terminal de Atendimento Exclusivo
/// Interface de alta densidade para suporte direto entre Investidor e Back-Office.
class SuporteConciergeScreen extends StatefulWidget {
  const SuporteConciergeScreen({super.key});

  @override
  State<SuporteConciergeScreen> createState() => _SuporteConciergeScreenState();
}

class _SuporteConciergeScreenState extends State<SuporteConciergeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _mensagemController = TextEditingController();
  final TextEditingController _assuntoController = TextEditingController();

  bool _isSending = false;
  String _categoriaSelecionada = "Financeiro";
  String _prioridade = "Normal";

  final List<String> _categorias = [
    "Financeiro",
    "Ativos USA",
    "Compliance",
    "Geral"
  ];
  final List<String> _prioridades = ["Normal", "Alta", "Crítica"];

  // Paleta de Luxo CIG
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  void dispose() {
    _mensagemController.dispose();
    _assuntoController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE ABERTURA DE TICKET ---
  Future<void> _abrirTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    final User? user = FirebaseAuth.instance.currentUser;

    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('tickets').add({
          'investidor_uid': user.uid,
          'investidor_email': user.email,
          'assunto': _assuntoController.text.trim(),
          'mensagem_inicial': _mensagemController.text.trim(),
          'categoria': _categoriaSelecionada,
          'prioridade': _prioridade,
          'status': 'aberto', // aberto, em_analise, respondido, fechado
          'data_abertura': FieldValue.serverTimestamp(),
          'ultima_interacao': FieldValue.serverTimestamp(),
          'respostas': [],
        });

        if (mounted) {
          _assuntoController.clear();
          _mensagemController.clear();
          _showPrivateAlert("SOLICITAÇÃO ENVIADA",
              "Seu concierge recebeu o chamado e responderá em breve.");
        }
      }
    } catch (e) {
      _showPrivateAlert(
          "FALHA NA CONEXÃO", "Não foi possível contatar o servidor: $e",
          isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _showPrivateAlert(String title, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.redAccent : emerald,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: _buildConciergeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 50),

            // FORMULÁRIO DE NOVO CHAMADO
            _buildNewTicketForm(),
            const SizedBox(height: 80),

            // HISTÓRICO DE TICKETS ATIVOS
            _buildTicketHistorySection(),
            const SizedBox(height: 100),

            _buildConciergeFooter(),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DE INTERFACE ---

  PreferredSizeWidget _buildConciergeAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold),
      title: Text("PRIVATE CONCIERGE",
          style: GoogleFonts.cinzel(
              color: gold,
              fontSize: 13,
              letterSpacing: 3,
              fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CIG BACK-OFFICE DIRECT",
            style: TextStyle(
                color: gold.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 12),
        Text("SUPORTE EXECUTIVO",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text(
          "Inicie um diálogo direto com nossa mesa de operações para dúvidas sobre aportes, ativos imobiliários ou documentação USA.",
          style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildNewTicketForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormLabel("NATUREZA DA SOLICITAÇÃO"),
          const SizedBox(height: 20),
          _buildCategoryGrid(),
          const SizedBox(height: 40),
          _buildFormLabel("DETALHES DO CHAMADO"),
          const SizedBox(height: 20),
          _buildTextField(
              "Assunto Resumido", _assuntoController, Icons.topic_outlined),
          const SizedBox(height: 20),
          _buildLargeTextField(
              "Descreva sua necessidade em detalhes...", _mensagemController),
          const SizedBox(height: 40),
          _buildPrioritySelector(),
          const SizedBox(height: 50),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Row(
      children: [
        Container(width: 25, height: 1, color: gold),
        const SizedBox(width: 15),
        Text(text,
            style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: _categorias.map((cat) {
        bool isSelected = _categoriaSelecionada == cat;
        return InkWell(
          onTap: () => setState(() => _categoriaSelecionada = cat),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            decoration: BoxDecoration(
              color: isSelected ? gold : Colors.white.withValues(alpha: 0.03),
              border: Border.all(color: isSelected ? gold : Colors.white10),
            ),
            child: Text(cat.toUpperCase(),
                style: TextStyle(
                    color: isSelected ? navy : Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(
      String hint, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (v) => v!.isEmpty ? "Campo obrigatório" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white12),
        prefixIcon: Icon(icon, color: gold, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold)),
      ),
    );
  }

  Widget _buildLargeTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 6,
      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
      validator: (v) => v!.isEmpty ? "Descreva o problema" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold)),
        contentPadding: const EdgeInsets.all(25),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: [
        const Text("URGÊNCIA:",
            style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 30),
        ..._prioridades.map((p) {
          bool isSelected = _prioridade == p;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ChoiceChip(
              label: Text(p,
                  style: TextStyle(
                      color: isSelected ? navy : Colors.white24, fontSize: 10)),
              selected: isSelected,
              onSelected: (val) => setState(() => _prioridade = p),
              selectedColor: gold,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: isSelected ? gold : Colors.white10)),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _isSending ? null : _abrirTicket,
        style: ElevatedButton.styleFrom(
            backgroundColor: gold, foregroundColor: navy),
        child: _isSending
            ? const CircularProgressIndicator(color: Color(0xFF050F22))
            : Text("ESTABELECER CONEXÃO COM CONCIERGE",
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildTicketHistorySection() {
    final User? user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormLabel("MEUS CHAMADOS RECENTES"),
        const SizedBox(height: 30),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tickets')
              .where('investidor_uid', isEqualTo: user?.uid)
              .orderBy('data_abertura', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const LinearProgressIndicator();
            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const Center(
                  child: Text("Nenhuma solicitação aberta.",
                      style: TextStyle(color: Colors.white10, fontSize: 12)));
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final ticket = docs[index].data() as Map<String, dynamic>;
                return _ticketTile(ticket);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _ticketTile(Map<String, dynamic> ticket) {
    Color statusColor = Colors.orange;
    if (ticket['status'] == 'respondido') statusColor = emerald;
    if (ticket['status'] == 'fechado') statusColor = Colors.white24;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(ticket['categoria'].toUpperCase(),
                  style: TextStyle(
                      color: gold,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: statusColor.withValues(alpha: 0.1),
                child: Text(
                    ticket['status']
                        .toString()
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(ticket['assunto'],
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          const SizedBox(height: 10),
          Text(ticket['mensagem_inicial'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 20),
          if (ticket['respostas'].isNotEmpty)
            _adminReplyPreview(ticket['respostas'].last),
        ],
      ),
    );
  }

  Widget _adminReplyPreview(Map<String, dynamic> lastReply) {
    return Container(
      padding: const EdgeInsets.all(15),
      color: emerald.withValues(alpha: 0.05),
      child: Row(
        children: [
          const Icon(Icons.reply, color: Colors.green, size: 16),
          const SizedBox(width: 15),
          Expanded(
            child: Text("Última resposta: ${lastReply['mensagem']}",
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  Widget _buildConciergeFooter() {
    return const Center(
      child: Column(
        children: [
          Text("CIG PRIVATE INVESTMENT GROUP • FLORIDA USA",
              style: TextStyle(
                  color: Colors.white10, fontSize: 8, letterSpacing: 2.5)),
          SizedBox(height: 10),
          Text("SECURED ENCRYPTED CHANNEL",
              style: TextStyle(color: Colors.white10, fontSize: 7)),
        ],
      ),
    );
  }
}
