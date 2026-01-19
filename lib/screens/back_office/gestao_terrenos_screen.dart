import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgt_projeto/models/terreno_model.dart';

class GestaoTerrenosScreen extends StatefulWidget {
  const GestaoTerrenosScreen({super.key});

  @override
  State<GestaoTerrenosScreen> createState() => _GestaoTerrenosScreenState();
}

class _GestaoTerrenosScreenState extends State<GestaoTerrenosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para abrir o formulário de cadastro
  void _abrirFormularioCadastro() {
    final nomeController = TextEditingController();
    final localController = TextEditingController();
    final precoController = TextEditingController();
    String statusSelecionado = 'Disponível';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            const Text(
              "Novo Terreno",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(
                labelText: "Nome do Lote/Terreno",
              ),
            ),
            TextField(
              controller: localController,
              decoration: const InputDecoration(
                labelText: "Localização/Endereço",
              ),
            ),
            TextField(
              controller: precoController,
              decoration: const InputDecoration(labelText: "Preço de Venda"),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: statusSelecionado,
              items: [
                'Disponível',
                'Em Negociação',
                'Vendido',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => statusSelecionado = val!,
              decoration: const InputDecoration(labelText: "Status Inicial"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('terrenos').add({
                  'nome': nomeController.text,
                  'localizacao': localController.text,
                  'preco': double.parse(precoController.text),
                  'status': statusSelecionado,
                  'documentoUrl': '',
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
              child: const Text("SALVAR TERRENO"),
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
        title: const Text("Gestão de Terrenos"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('terrenos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
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
                  leading: const Icon(Icons.landscape, color: Colors.green),
                  title: Text(
                    terreno.nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${terreno.localizacao} - R\$ ${terreno.preco}",
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: terreno.status == 'Vendido'
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      terreno.status,
                      style: TextStyle(
                        color: terreno.status == 'Vendido'
                            ? Colors.red
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioCadastro,
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
