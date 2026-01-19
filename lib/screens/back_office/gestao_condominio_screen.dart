import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgt_projeto/models/terreno_model.dart';

class GestaoCondominioScreen extends StatefulWidget {
  const GestaoCondominioScreen({super.key});

  @override
  State<GestaoCondominioScreen> createState() => _GestaoCondominioScreenState();
}

class _GestaoCondominioScreenState extends State<GestaoCondominioScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para abrir o formulário de definição de valor de condomínio
  void _editarCondominio(Terreno terreno) {
    final valorController = TextEditingController();
    final instrucoesController = TextEditingController();
    final vencimentoController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Condomínio: ${terreno.nome}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: valorController,
              decoration: const InputDecoration(
                labelText: "Valor Mensal (R\$)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: vencimentoController,
              decoration: const InputDecoration(
                labelText: "Dia de Vencimento (Ex: 10)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: instrucoesController,
              decoration: const InputDecoration(
                labelText: "Instruções (Chave PIX, Link, etc.)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('condominios').doc(terreno.id).set({
                  'terrenoId': terreno.id,
                  'valor': double.tryParse(valorController.text) ?? 0.0,
                  'dataVencimento': vencimentoController.text,
                  'instrucoesPagamento': instrucoesController.text,
                  'ultimaAtualizacao': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text("SALVAR INFORMAÇÕES"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestão de Condomínio"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('terrenos')
            .where('status', isEqualTo: 'Vendido')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("Nenhum terreno vendido para gerir condomínio."),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final terreno = Terreno.fromMap(
                docs[index].data() as Map<String, dynamic>,
                docs[index].id,
              );
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.home_work, color: Colors.blueGrey),
                  title: Text(terreno.nome),
                  subtitle: const Text(
                    "Clique para configurar taxas e pagamentos",
                  ),
                  trailing: const Icon(Icons.edit, color: Color(0xFF1A237E)),
                  onTap: () => _editarCondominio(terreno),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
