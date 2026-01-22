import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central de Operações de Suporte v1.0
/// Gestão de Tickets de Investidores com Motor de Resposta Direta.
class GestaoSuporteScreen extends StatefulWidget {
  const GestaoSuporteScreen({super.key});

  @override
  State<GestaoSuporteScreen> createState() => _GestaoSuporteScreenState();
}

class _GestaoSuporteScreenState extends State<GestaoSuporteScreen> {
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  String _filtroStatus = "aberto";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("MESA DE ATENDIMENTO PRIVATE",
            style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildTicketStream()),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _filterItem("aberto", "PENDENTES"),
          _filterItem("respondido", "AGUARDANDO"),
          _filterItem("fechado", "CONCLUÍDOS"),
        ],
      ),
    );
  }

  Widget _filterItem(String status, String label) {
    bool active = _filtroStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filtroStatus = status),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: active ? gold : Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
          if (active)
            Container(
                margin: const EdgeInsets.only(top: 8),
                width: 20,
                height: 2,
                color: gold),
        ],
      ),
    );
  }

  Widget _buildTicketStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tickets')
          .where('status', isEqualTo: _filtroStatus)
          .orderBy('ultima_interacao', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        if (docs.isEmpty) return _buildEmptyState();

        return ListView.builder(
          padding: const EdgeInsets.all(30),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final ticket = docs[index].data() as Map<String, dynamic>;
            final id = docs[index].id;
            return _adminTicketCard(id, ticket);
          },
        );
      },
    );
  }

  Widget _adminTicketCard(String id, Map<String, dynamic> ticket) {
    Color priorityColor = ticket['prioridade'] == 'Crítica' ? Colors.red : gold;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(20),
        leading: CircleAvatar(
          backgroundColor: priorityColor.withValues(alpha: 0.1),
          child: Icon(Icons.support_agent, color: priorityColor, size: 20),
        ),
        title: Text(ticket['assunto'],
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
              "INVESTIDOR: ${ticket['investidor_email']} • ${ticket['categoria']}",
              style: const TextStyle(color: Colors.white24, fontSize: 10)),
        ),
        children: [
          _buildTicketDetails(id, ticket),
        ],
      ),
    );
  }

  Widget _buildTicketDetails(String id, Map<String, dynamic> ticket) {
    final TextEditingController replyController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(30),
      color: Colors.black.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("MENSAGEM DO INVESTIDOR:",
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(ticket['mensagem_inicial'],
              style: const TextStyle(color: Colors.white, height: 1.6)),
          const Divider(height: 50, color: Colors.white10),
          if (ticket['respostas'].isNotEmpty) ...[
            const Text("HISTÓRICO DE RESPOSTAS:",
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            ...ticket['respostas'].map<Widget>((r) => _replyBubble(r)).toList(),
            const SizedBox(height: 30),
          ],
          _buildReplyInput(id, replyController),
        ],
      ),
    );
  }

  Widget _replyBubble(Map<String, dynamic> reply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: emerald.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("RESPOSTA BACK-OFFICE",
                style: TextStyle(
                    color: emerald, fontSize: 8, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(reply['mensagem'],
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyInput(String id, TextEditingController controller) {
    return Column(
      children: [
        TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: "Sua resposta executiva...",
            hintStyle: const TextStyle(color: Colors.white10),
            filled: true,
            fillColor: Colors.black38,
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: emerald)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _enviarResposta(id, controller.text),
                style: ElevatedButton.styleFrom(backgroundColor: emerald),
                child: const Text("ENVIAR RESPOSTA",
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 15),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.white24),
              onPressed: () => _encerrarTicket(id),
              tooltip: "Fechar Ticket",
            ),
          ],
        )
      ],
    );
  }

  Future<void> _enviarResposta(String id, String msg) async {
    if (msg.isEmpty) return;
    await FirebaseFirestore.instance.collection('tickets').doc(id).update({
      'status': 'respondido',
      'ultima_interacao': FieldValue.serverTimestamp(),
      'respostas': FieldValue.arrayUnion([
        {
          'mensagem': msg,
          'data': DateTime.now().toIso8601String(),
          'autor': 'Back-Office'
        }
      ])
    });
  }

  Future<void> _encerrarTicket(String id) async {
    await FirebaseFirestore.instance
        .collection('tickets')
        .doc(id)
        .update({'status': 'fechado'});
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, color: Colors.white10, size: 60),
          SizedBox(height: 20),
          Text("NENHUM CHAMADO NESTA CATEGORIA",
              style: TextStyle(color: Colors.white10, letterSpacing: 2)),
        ],
      ),
    );
  }
}
