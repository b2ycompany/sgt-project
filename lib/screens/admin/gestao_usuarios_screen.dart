import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class GestaoUsuariosScreen extends StatefulWidget {
  const GestaoUsuariosScreen({super.key});

  @override
  State<GestaoUsuariosScreen> createState() => _GestaoUsuariosScreenState();
}

class _GestaoUsuariosScreenState extends State<GestaoUsuariosScreen> {
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text(
          "CONTROLE DE COMPLIANCE / KYC",
          style: GoogleFonts.cinzel(
              color: gold, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuta apenas utilizadores pendentes para aprovação
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .where('status', isEqualTo: 'pendente')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_search,
                      color: gold.withValues(alpha: 0.3), size: 60),
                  const SizedBox(height: 20),
                  const Text("Nenhuma solicitação de acesso pendente.",
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final String docId = users[index].id;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: gold.withValues(alpha: 0.2),
                    child: Icon(Icons.person, color: gold),
                  ),
                  title: Text(
                    userData['nome'] ?? 'Investidor Anônimo',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Perfil: ${userData['perfil_investidor'] ?? 'Não definido'}\n${userData['email'] ?? ''}",
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão Aprovar
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.green),
                        onPressed: () => _updateUserStatus(docId, 'aprovado'),
                        tooltip: "Aprovar Acesso",
                      ),
                      const SizedBox(width: 8),
                      // Botão Reprovar
                      IconButton(
                        icon: const Icon(Icons.block_flipped,
                            color: Colors.redAccent),
                        onPressed: () => _updateUserStatus(docId, 'recusado'),
                        tooltip: "Negar Acesso",
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Função para atualizar status do utilizador no Firestore
  Future<void> _updateUserStatus(String uid, String status) async {
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'status': status,
        'data_analise': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Utilizador $status com sucesso.")),
        );
      }
    } catch (e) {
      debugPrint("Erro ao atualizar status: $e");
    }
  }
}
