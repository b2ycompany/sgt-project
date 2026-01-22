import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sgt_projeto/screens/admin/edicao_ativos_screen.dart'; // Certifique-se de criar este arquivo

/// HUB DE PORTFÓLIO v5.2 - CIG PRIVATE INVESTMENT
/// Centraliza Criação, Listagem, Edição e Exclusão de Ativos USA.
class GestaoInvestimentosScreen extends StatefulWidget {
  const GestaoInvestimentosScreen({super.key});

  @override
  State<GestaoInvestimentosScreen> createState() =>
      _GestaoInvestimentosScreenState();
}

class _GestaoInvestimentosScreenState extends State<GestaoInvestimentosScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // --- ESTADO LANÇAMENTO ---
  String _tipoAtivo = "Terreno";
  List<File> _imagensSelecionadas = [];
  final ImagePicker _picker = ImagePicker();

  // CONTROLADORES
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _roiController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _metragemController = TextEditingController();
  final TextEditingController _quartosController = TextEditingController();
  final TextEditingController _custoReformaController = TextEditingController();
  final TextEditingController _prazoObraController = TextEditingController();

  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color alertRed = const Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _localController.dispose();
    _roiController.dispose();
    _precoController.dispose();
    _metragemController.dispose();
    _quartosController.dispose();
    _custoReformaController.dispose();
    _prazoObraController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE EXCLUSÃO (MÓDULO SOLICITADO) ---
  Future<void> _confirmarExclusao(String docId, String titulo) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: navy,
        title: Text("EXCLUIR ATIVO?",
            style: GoogleFonts.cinzel(
                color: alertRed, fontWeight: FontWeight.bold)),
        content: Text(
            "Esta ação removerá '$titulo' permanentemente do portal e dos aplicativos dos investidores.",
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("CANCELAR")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: alertRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("EXCLUIR DEFINITIVAMENTE"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('ofertas')
            .doc(docId)
            .delete();
        _notificar("Ativo removido do inventário.");
      } catch (e) {
        _notificar("Erro ao excluir: $e", isError: true);
      }
    }
  }

  // --- LÓGICA DE CRIAÇÃO (MANTENDO INTEGRIDADE) ---
  Future<void> _publicarNovoAtivo() async {
    if (!_formKey.currentState!.validate() || _imagensSelecionadas.isEmpty)
      return;
    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('ofertas').doc();
      List<String> urls = [];
      for (int i = 0; i < _imagensSelecionadas.length; i++) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('ofertas/${docRef.id}/img_$i.jpg');
        await ref.putFile(_imagensSelecionadas[i]);
        urls.add(await ref.getDownloadURL());
      }

      await docRef.set({
        'id': docRef.id,
        'tipo': _tipoAtivo,
        'titulo': _tituloController.text.trim(),
        'localizacao': _localController.text.trim(),
        'roi_estimado': _roiController.text.trim(),
        'preco_lote': _precoController.text.trim(),
        'imagens_urls': urls,
        'status': 'ativo',
        'data_criacao': FieldValue.serverTimestamp(),
        'especificacoes': {
          'area_acres': _metragemController.text,
          'rooms': _quartosController.text,
          'budget_work': _custoReformaController.text,
          'timeline_months': _prazoObraController.text,
        }
      });

      _notificar("Ativo $_tipoAtivo lançado com sucesso!");
      _tabController.animateTo(1);
    } catch (e) {
      _notificar("Erro no upload: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _notificar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? alertRed : Colors.green));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("PORTFÓLIO DE ATIVOS USA",
            style: GoogleFonts.cinzel(
                color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: gold,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          tabs: const [
            Tab(text: "LANÇAR OFERTA"),
            Tab(text: "GERENCIAR INVENTÁRIO"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateView(),
          _buildManageListView(),
        ],
      ),
    );
  }

  // --- VISUALIZAÇÃO: ABA DE CRIAÇÃO ---
  Widget _buildCreateView() {
    return _isLoading
        ? Center(child: CircularProgressIndicator(color: gold))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(40),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  _buildTypeSelector(),
                  const SizedBox(height: 40),
                  _buildMediaPicker(),
                  const SizedBox(height: 40),
                  _buildField("Título", _tituloController, Icons.title),
                  _buildField(
                      "Localização", _localController, Icons.location_on),
                  Row(children: [
                    Expanded(
                        child: _buildField(
                            "ROI %", _roiController, Icons.trending_up,
                            keyboard: TextInputType.number)),
                    const SizedBox(width: 20),
                    Expanded(
                        child: _buildField("Preço USD", _precoController,
                            Icons.monetization_on,
                            keyboard: TextInputType.number)),
                  ]),
                  const SizedBox(height: 60),
                  _buildSubmitButton(),
                ])),
          );
  }

  // --- VISUALIZAÇÃO: ABA DE GERENCIAMENTO (LISTA) ---
  Widget _buildManageListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ofertas')
          .orderBy('data_criacao', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator(color: gold));
        final docs = snapshot.data!.docs;

        if (docs.isEmpty)
          return const Center(
              child: Text("NENHUM ATIVO EM CARTEIRA.",
                  style: TextStyle(
                      color: Colors.white12, fontSize: 12, letterSpacing: 2)));

        return ListView.builder(
          padding: const EdgeInsets.all(25),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String id = docs[index].id;
            final String firstImg = (data['imagens_urls'] as List).isNotEmpty
                ? data['imagens_urls'][0]
                : "";

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),
                leading: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(firstImg), fit: BoxFit.cover))),
                title: Text(data['titulo'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                subtitle: Text(
                    "${data['tipo'].toUpperCase()} • ROI: ${data['roi_estimado']}% • \$ ${data['preco_lote']}",
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 10)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_square, color: gold, size: 22),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EdicaoAtivosScreen(
                                  assetId: id, assetData: data))),
                    ),
                    IconButton(
                      icon:
                          Icon(Icons.delete_outline, color: alertRed, size: 22),
                      onPressed: () => _confirmarExclusao(id, data['titulo']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- REUTILIZAÇÃO DE COMPONENTES ---
  Widget _buildTypeSelector() {
    return Row(
        children: ["Terreno", "Casa", "Reforma"]
            .map((t) => Expanded(
                child: GestureDetector(
                    onTap: () => setState(() => _tipoAtivo = t),
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            color: _tipoAtivo == t
                                ? gold
                                : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                                color:
                                    _tipoAtivo == t ? gold : Colors.white10)),
                        child: Center(
                            child: Text(t.toUpperCase(),
                                style: TextStyle(
                                    color:
                                        _tipoAtivo == t ? navy : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)))))))
            .toList());
  }

  Widget _buildMediaPicker() {
    return InkWell(
        onTap: () async {
          final List<XFile> imgs = await _picker.pickMultiImage();
          if (imgs.isNotEmpty)
            setState(() =>
                _imagensSelecionadas = imgs.map((e) => File(e.path)).toList());
        },
        child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(50),
            decoration: BoxDecoration(
                border: Border.all(
                    color: gold.withValues(alpha: 0.2),
                    style: BorderStyle.solid)),
            child: Column(children: [
              Icon(Icons.add_a_photo_outlined, color: gold, size: 40),
              const SizedBox(height: 10),
              Text("SELECIONAR GALERIA DO ATIVO",
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold))
            ])));
  }

  Widget _buildField(String l, TextEditingController c, IconData i,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: TextFormField(
            controller: c,
            keyboardType: keyboard,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
                labelText: l,
                labelStyle:
                    const TextStyle(color: Colors.white38, fontSize: 12),
                prefixIcon: Icon(i, color: gold),
                enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white10)))));
  }

  Widget _buildSubmitButton() {
    return SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton(
            onPressed: _publicarNovoAtivo,
            style: ElevatedButton.styleFrom(
                backgroundColor: gold, foregroundColor: navy),
            child: Text("LANÇAR ATIVO NO PORTAL PRIVATE",
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold, letterSpacing: 1.5))));
  }
}
