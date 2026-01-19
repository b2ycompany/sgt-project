import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgt_projeto/models/terreno_model.dart';
import 'package:sgt_projeto/screens/back_office/gestao_documentos_screen.dart';

class GestaoTerrenosScreen extends StatefulWidget {
  const GestaoTerrenosScreen({super.key});

  @override
  State<GestaoTerrenosScreen> createState() => _GestaoTerrenosScreenState();
}

class _GestaoTerrenosScreenState extends State<GestaoTerrenosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Define as cores para cada status de forma profissional
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Disponível':
        return Colors.green.shade600;
      case 'Em Negociação':
        return Colors.orange.shade600;
      case 'Vendido':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }

  // Função para abrir o formulário de cadastro de novos terrenos
  void _abrirFormularioCadastro() {
    final TextEditingController nomeController = TextEditingController();
    final TextEditingController localizacaoController = TextEditingController();
    final TextEditingController precoController = TextEditingController();
    String statusSelecionado = 'Disponível';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 30,
          left: 25,
          right: 25,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Cadastrar Novo Terreno",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do Lote/Empreendimento",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: localizacaoController,
                decoration: const InputDecoration(
                  labelText: "Localização Completa",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: precoController,
                decoration: const InputDecoration(
                  labelText: "Preço de Venda (R\$)",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: statusSelecionado,
                decoration: const InputDecoration(
                  labelText: "Status Atual",
                  border: OutlineInputBorder(),
                ),
                items: ['Disponível', 'Em Negociação', 'Vendido']
                    .map(
                      (String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: (newValue) {
                  statusSelecionado = newValue!;
                },
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  if (nomeController.text.isNotEmpty &&
                      precoController.text.isNotEmpty) {
                    await _firestore.collection('terrenos').add({
                      'nome': nomeController.text,
                      'localizacao': localizacaoController.text,
                      'preco': double.tryParse(precoController.text) ?? 0.0,
                      'status': statusSelecionado,
                      'documentoUrl': '',
                      'dataCriacao': FieldValue.serverTimestamp(),
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "CONFIRMAR CADASTRO",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
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
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(color: Colors.grey.shade100),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('terrenos')
              .orderBy('dataCriacao', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text("Nenhum terreno cadastrado no sistema."),
              );
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final Map<String, dynamic> data =
                    docs[index].data() as Map<String, dynamic>;
                final terreno = Terreno.fromMap(data, docs[index].id);

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(
                        terreno.status,
                      ).withOpacity(0.1),
                      child: Icon(
                        Icons.landscape,
                        color: _getStatusColor(terreno.status),
                      ),
                    ),
                    title: Text(
                      terreno.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text("Local: ${terreno.localizacao}"),
                        Text(
                          "Valor: R\$ ${terreno.preco.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(terreno.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            terreno.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onTap: () {
                      // Ao clicar, abre a gestão de documentos para vincular arquivos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GestaoDocumentosScreen(
                            terrenoId: terreno.id,
                            terrenoNome: terreno.nome,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirFormularioCadastro,
        backgroundColor: const Color(0xFF1A237E),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
