import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:sgt_projeto/models/terreno_model.dart';

class WorkflowKanbanScreen extends StatefulWidget {
  const WorkflowKanbanScreen({super.key});

  @override
  State<WorkflowKanbanScreen> createState() => _WorkflowKanbanScreenState();
}

class _WorkflowKanbanScreenState extends State<WorkflowKanbanScreen> {
  // Etapas do Workflow da CIG Investimento
  final List<String> _etapas = [
    'Disponível',
    'Em Negociação',
    'Vendido',
    'Repasse a Parceiros',
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Atualização segura do status no Firebase
  Future<void> _atualizarStatusTerreno(
    String terrenoId,
    String novoStatus,
  ) async {
    try {
      await _firestore.collection('terrenos').doc(terrenoId).update({
        'status': novoStatus,
        'ultimaAtualizacao': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Workflow atualizado: Terreno movido para $novoStatus"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao atualizar workflow: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Workflow de Vendas (Kanban)"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('terrenos').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Terreno> todosTerrenos = snapshot.data!.docs.map((doc) {
            return Terreno.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return DragAndDropLists(
            // Configurações visuais para o Kanban
            children: _etapas.map((etapa) {
              return _buildKanbanColumn(etapa, todosTerrenos);
            }).toList(),
            onItemReorder:
                (
                  int oldItemIndex,
                  int oldListIndex,
                  int newItemIndex,
                  int newListIndex,
                ) {
                  if (oldListIndex != newListIndex) {
                    // Lógica de movimentação entre colunas
                    List<Terreno> listaOrigem = _getTerrenosPorEtapa(
                      todosTerrenos,
                      _etapas[oldListIndex],
                    );
                    String terrenoId = listaOrigem[oldItemIndex].id;
                    String novoStatus = _etapas[newListIndex];

                    _atualizarStatusTerreno(terrenoId, novoStatus);
                  }
                },
            onListReorder: (int oldListIndex, int newListIndex) {
              // Etapas são fixas conforme o processo de negócio da CIG
            },
            axis: Axis.horizontal,
            listPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            listWidth: 300,
            // Customização para visual de sistema de ponta
            listInnerDecoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }

  List<Terreno> _getTerrenosPorEtapa(List<Terreno> lista, String etapa) {
    return lista.where((t) => t.status == etapa).toList();
  }

  DragAndDropList _buildKanbanColumn(
    String titulo,
    List<Terreno> listaCompleta,
  ) {
    List<Terreno> terrenosDaEtapa = _getTerrenosPorEtapa(listaCompleta, titulo);

    return DragAndDropList(
      header: Container(
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          color: Color(0xFF1A237E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: Text(
                "${terrenosDaEtapa.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      children: terrenosDaEtapa.map((terreno) {
        return DragAndDropItem(
          child: Card(
            elevation: 1,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              title: Text(
                terreno.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                "R\$ ${terreno.preco.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(
                Icons.drag_indicator,
                size: 20,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
