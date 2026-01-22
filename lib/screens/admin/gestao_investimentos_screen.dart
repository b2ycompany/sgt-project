import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// HUB DE LANÇAMENTO MULTI-ATIVOS v6.0 - CIG PRIVATE
/// Suporte Integral: Terrenos, Casas e Reformas. Habilitado para Web/Mobile.
class GestaoInvestimentosScreen extends StatefulWidget {
  const GestaoInvestimentosScreen({super.key});

  @override
  State<GestaoInvestimentosScreen> createState() =>
      _GestaoInvestimentosScreenState();
}

class _GestaoInvestimentosScreenState extends State<GestaoInvestimentosScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // ESTADO DOS ATIVOS
  String _activeType = "Terreno";
  final List<XFile> _queuedMedia = [];
  final ImagePicker _mediaPicker = ImagePicker();

  // CONTROLADORES
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _roiCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();
  final TextEditingController _roomCtrl = TextEditingController();
  final TextEditingController _renovBudgetCtrl = TextEditingController();
  final TextEditingController _deadlineCtrl = TextEditingController();

  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _roiCtrl.dispose();
    _priceCtrl.dispose();
    _areaCtrl.dispose();
    _roomCtrl.dispose();
    _renovBudgetCtrl.dispose();
    _deadlineCtrl.dispose();
    super.dispose();
  }

  // --- MOTOR DE MÍDIA COM LOGS (WEB COMPATIBLE) ---
  Future<void> _pickMedia() async {
    debugPrint("--- [SGT LOG]: Abrindo Seletor de Mídias Multi-Ativo ---");
    try {
      final List<XFile> selection = await _mediaPicker.pickMultiImage();
      if (selection.isNotEmpty) {
        setState(() => _queuedMedia.addAll(selection));
        debugPrint(
            "--- [SGT LOG]: ${selection.length} imagens em fila de processamento ---");
      }
    } catch (e) {
      debugPrint("--- [SGT ERRO]: Falha ao acessar galeria -> $e ---");
    }
  }

  Future<List<String>> _uploadStorage(String folderId) async {
    List<String> results = [];
    debugPrint(
        "--- [SGT LOG]: Iniciando Ciclo de Upload para Firebase Storage ---");

    for (int i = 0; i < _queuedMedia.length; i++) {
      try {
        final ref = FirebaseStorage.instance
            .ref()
            .child('ofertas/$folderId/img_$i.jpg');

        // CORREÇÃO CRÍTICA PARA VERCEL/WEB: Ler bytes em vez de caminho de arquivo
        final bytes = await _queuedMedia[i].readAsBytes();
        final meta = SettableMetadata(contentType: 'image/jpeg');

        debugPrint(
            "--- [SGT LOG]: Enviando Buffer de Imagem $i (${bytes.length} bytes)... ---");
        await ref.putData(bytes, meta);

        String url = await ref.getDownloadURL();
        results.add(url);
        debugPrint("--- [SGT LOG]: Upload Concluído ID: $i -> URL: $url ---");
      } catch (e) {
        debugPrint("--- [SGT ERRO]: Falha crítica no Storage ID $i -> $e ---");
        throw Exception("Falha de Comunicação com Storage USA.");
      }
    }
    return results;
  }

  Future<void> _anunciarAtivo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_queuedMedia.isEmpty) {
      _showToast("O Ativo Private exige comprovação visual.", isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    debugPrint(
        "--- [SGT LOG]: Iniciando Protocolo de Publicação Multi-Ativo ---");

    try {
      final docRef = FirebaseFirestore.instance.collection('ofertas').doc();

      // Upload para Cloud
      List<String> cloudUrls = await _uploadStorage(docRef.id);

      // Estrutura de Metadados Absoluta
      Map<String, dynamic> data = {
        'id': docRef.id,
        'tipo': _activeType,
        'titulo': _titleCtrl.text.trim(),
        'localizacao': _locationCtrl.text.trim(),
        'roi_estimado': _roiCtrl.text.trim(),
        'preco_lote': _priceCtrl.text.trim(),
        'imagens_urls': cloudUrls,
        'status': 'ativo',
        'data_criacao': FieldValue.serverTimestamp(),
        'especificacoes': {
          if (_activeType == "Terreno") 'area_total': _areaCtrl.text,
          if (_activeType == "Casa") ...{
            'sqft': _areaCtrl.text,
            'rooms': _roomCtrl.text
          },
          if (_activeType == "Reforma") ...{
            'reforma_usd': _renovBudgetCtrl.text,
            'prazo': _deadlineCtrl.text
          }
        }
      };

      debugPrint("--- [SGT LOG]: Sincronizando com Firestore DB... ---");
      await docRef.set(data);
      debugPrint("--- [SGT LOG]: ATIVO PUBLICADO COM SUCESSO ABSOLUTO ---");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("ATIVO USA PUBLICADO NO PORTAL PRIVATE")));
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("--- [SGT ERRO FATAL]: $e ---");
      _showToast("Falha técnica no lançamento: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showToast(String m, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(m),
        backgroundColor: isError ? Colors.redAccent : emerald));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("LANÇAMENTO DE ATIVOS USA",
            style: GoogleFonts.cinzel(
                color: gold, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircularProgressIndicator(color: gold),
                  const SizedBox(height: 30),
                  Text("SINCRONIZANDO ATIVOS NO SERVIDOR USA...",
                      style: GoogleFonts.cinzel(color: gold, fontSize: 11))
                ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader("CATEGORIA DO ATIVO"),
                    const SizedBox(height: 25),
                    _buildAssetSelector(),
                    const SizedBox(height: 50),
                    _buildHeader("CURADORIA VISUAL (WEB COMPATIBLE)"),
                    const SizedBox(height: 25),
                    _buildMediaGrid(),
                    const SizedBox(height: 50),
                    _buildHeader("DADOS FINANCEIROS E COMERCIAIS"),
                    const SizedBox(height: 30),
                    _buildInput("Título do Ativo", _titleCtrl, Icons.business),
                    const SizedBox(height: 20),
                    _buildInput(
                        "Localização / County", _locationCtrl, Icons.map),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(
                          child: _buildInput(
                              "ROI %", _roiCtrl, Icons.trending_up,
                              k: TextInputType.number)),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildInput("Preço Total USD", _priceCtrl,
                              Icons.monetization_on,
                              k: TextInputType.number)),
                    ]),
                    const SizedBox(height: 50),
                    _buildHeader("ESPECIFICAÇÕES TÉCNICAS ($_activeType)"),
                    const SizedBox(height: 30),
                    _buildDynamicForm(),
                    const SizedBox(height: 80),
                    _buildAnounceButton(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(String t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t,
          style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 2)),
      const SizedBox(height: 8),
      Container(width: 40, height: 2, color: gold),
    ]);
  }

  Widget _buildAssetSelector() {
    return Row(
        children: ["Terreno", "Casa", "Reforma"].map((t) {
      bool active = _activeType == t;
      return Expanded(
          child: InkWell(
              onTap: () => setState(() => _activeType = t),
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  decoration: BoxDecoration(
                      color:
                          active ? gold : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: active ? gold : Colors.white10),
                      borderRadius: BorderRadius.circular(4)),
                  child: Center(
                      child: Text(t.toUpperCase(),
                          style: TextStyle(
                              color: active ? navy : Colors.white60,
                              fontSize: 10,
                              fontWeight: FontWeight.bold))))));
    }).toList());
  }

  Widget _buildMediaGrid() {
    return Column(children: [
      InkWell(
          onTap: _pickMedia,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(60),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  border: Border.all(
                      color: gold.withValues(alpha: 0.2),
                      style: BorderStyle.solid)),
              child: Column(children: [
                Icon(Icons.add_photo_alternate_outlined, color: gold, size: 45),
                const SizedBox(height: 15),
                const Text("SELECIONAR IMAGENS DO ATIVO",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.bold))
              ]))),
      if (_queuedMedia.isNotEmpty)
        Container(
            height: 140,
            margin: const EdgeInsets.only(top: 25),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _queuedMedia.length,
                itemBuilder: (context, index) => Stack(children: [
                      Container(
                          width: 140,
                          margin: const EdgeInsets.only(right: 15),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(_queuedMedia[index].path),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white10))),
                      Positioned(
                          top: 5,
                          right: 20,
                          child: GestureDetector(
                              onTap: () =>
                                  setState(() => _queuedMedia.removeAt(index)),
                              child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      size: 14, color: Colors.white))))
                    ]))),
    ]);
  }

  Widget _buildDynamicForm() {
    if (_activeType == "Terreno")
      return _buildInput(
          "Área Total (Sqft / Acres)", _areaCtrl, Icons.landscape);
    if (_activeType == "Casa")
      return Column(children: [
        _buildInput("Living Area (Sqft)", _areaCtrl, Icons.straighten),
        const SizedBox(height: 20),
        _buildInput("Suítes / Quartos", _roomCtrl, Icons.bed)
      ]);
    return Column(children: [
      _buildInput("Budget de Reforma (USD)", _renovBudgetCtrl, Icons.handyman,
          k: TextInputType.number),
      const SizedBox(height: 20),
      _buildInput("Prazo Previsto (Meses)", _deadlineCtrl, Icons.av_timer)
    ]);
  }

  Widget _buildInput(String l, TextEditingController c, IconData i,
      {TextInputType k = TextInputType.text}) {
    return TextFormField(
        controller: c,
        keyboardType: k,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        validator: (v) => v!.isEmpty ? "Mandatório" : null,
        decoration: InputDecoration(
            labelText: l,
            labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
            prefixIcon: Icon(i, color: gold, size: 20),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: gold))));
  }

  Widget _buildAnounceButton() {
    return SizedBox(
        width: double.infinity,
        height: 75,
        child: ElevatedButton(
            onPressed: _anunciarAtivo,
            style: ElevatedButton.styleFrom(
                backgroundColor: gold, foregroundColor: navy, elevation: 20),
            child: Text("ANUNCIAR EMPREENDIMENTO NO PORTAL PRIVATE",
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 13))));
  }
}
