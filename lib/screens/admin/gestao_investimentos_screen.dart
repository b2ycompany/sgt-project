import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// HUB DE LANÇAMENTO MULTI-ATIVOS v6.2 - CIG PRIVATE INVESTMENT
/// Compatibilidade Total: Web (Vercel) e Mobile. Motor de Upload via Bytes.
class GestaoInvestimentosScreen extends StatefulWidget {
  const GestaoInvestimentosScreen({super.key});

  @override
  State<GestaoInvestimentosScreen> createState() =>
      _GestaoInvestimentosScreenState();
}

class _GestaoInvestimentosScreenState extends State<GestaoInvestimentosScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // ESTADO DOS ATIVOS E MÍDIAS
  String _activeType = "Terreno";
  final List<XFile> _queuedMedia = [];
  final ImagePicker _mediaPicker = ImagePicker();

  // CONTROLADORES DE ALTA DENSIDADE
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

  // --- MOTOR DE MÍDIA COM AUDITORIA (WEB COMPATIBLE) ---
  Future<void> _pickMedia() async {
    debugPrint("--- [SGT LOG]: Protocolo de Seleção de Mídias Iniciado ---");
    try {
      final List<XFile> selection = await _mediaPicker.pickMultiImage();
      if (selection.isNotEmpty) {
        setState(() => _queuedMedia.addAll(selection));
        debugPrint(
            "--- [SGT LOG]: Registro: ${selection.length} arquivos na fila ---");
      }
    } catch (e) {
      debugPrint("--- [SGT ERRO]: Falha no Hardware de Mídia -> $e ---");
    }
  }

  Future<List<String>> _runCloudUploadCycle(String folderId) async {
    List<String> cloudUrls = [];
    debugPrint(
        "--- [SGT LOG]: Sincronizando com Servidores de Mídia Firebase... ---");

    for (int i = 0; i < _queuedMedia.length; i++) {
      try {
        final Reference fileRef = FirebaseStorage.instance
            .ref()
            .child('ofertas/$folderId/img_$i.jpg');

        // LEITURA DE BYTES (Obrigatório para Vercel/Flutter Web)
        final bytes = await _queuedMedia[i].readAsBytes();
        final metadata = SettableMetadata(contentType: 'image/jpeg');

        debugPrint(
            "--- [SGT LOG]: Transmitindo Buffer $i (${bytes.length} bytes) ---");

        // Upload utilizando putData para evitar dependência de dart:io (File)
        await fileRef.putData(bytes, metadata);

        String downloadUrl = await fileRef.getDownloadURL();
        cloudUrls.add(downloadUrl);
        debugPrint(
            "--- [SGT LOG]: Link Gerado para Buffer $i -> $downloadUrl ---");
      } catch (e) {
        debugPrint(
            "--- [SGT ERRO CRÍTICO NO STORAGE]: Falha no índice $i -> $e ---");
        throw Exception("Storage Error: Unauthorized or Connection Refused.");
      }
    }
    return cloudUrls;
  }

  Future<void> _executarAnuncioAtivo() async {
    if (!_formKey.currentState!.validate()) return;
    if (_queuedMedia.isEmpty) {
      _triggerAlert("Curadoria visual obrigatória para o mercado Private.",
          isError: true);
      return;
    }

    setState(() => _isProcessing = true);
    debugPrint("--- [SGT LOG]: Iniciando Publicação Multi-Ativo no Portal ---");

    try {
      // 1. Geração de ID único via Firestore
      final DocumentReference docRef =
          FirebaseFirestore.instance.collection('ofertas').doc();

      // 2. Execução do Ciclo de Upload
      List<String> finalUrls = await _runCloudUploadCycle(docRef.id);

      // 3. Montagem do Payload de Metadados
      Map<String, dynamic> assetData = {
        'id': docRef.id,
        'tipo': _activeType,
        'titulo': _titleCtrl.text.trim(),
        'localizacao': _locationCtrl.text.trim(),
        'roi_estimado': _roiCtrl.text.trim(),
        'preco_lote': _priceCtrl.text.trim(),
        'imagens_urls': finalUrls,
        'status': 'ativa',
        'data_criacao': FieldValue.serverTimestamp(),
        'especificacoes': {
          if (_activeType == "Terreno") 'area': _areaCtrl.text,
          if (_activeType == "Casa") ...{
            'sqft': _areaCtrl.text,
            'rooms': _roomCtrl.text
          },
          if (_activeType == "Reforma") ...{
            'budget': _renovBudgetCtrl.text,
            'timeline': _deadlineCtrl.text
          }
        }
      };

      debugPrint("--- [SGT LOG]: Gravando Registro no Banco de Dados... ---");
      await docRef.set(assetData);
      debugPrint(
          "--- [SGT LOG]: ATIVO DISPONIBILIZADO COM SUCESSO ABSOLUTO ---");

      if (mounted) {
        _triggerAlert("ATIVO USA PUBLICADO NO MERCADO PRIVATE");
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("--- [SGT ERRO FATAL]: $e ---");
      _triggerAlert(
          "Falha técnica: Verifique as Rules do Storage no Firebase Console.",
          isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _triggerAlert(String m, {bool isError = false}) {
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
        title: Text("LANÇAMENTO DE ATIVOS SGT",
            style: GoogleFonts.cinzel(
                color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircularProgressIndicator(color: gold),
                  const SizedBox(height: 30),
                  Text("SINCRONIZANDO ATIVOS NO SERVIDOR USA...",
                      style: GoogleFonts.cinzel(color: gold, fontSize: 12))
                ]))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(50),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader("1. CLASSE DO ATIVO"),
                    const SizedBox(height: 30),
                    _buildAssetTypeSelector(),
                    const SizedBox(height: 60),
                    _buildHeader("2. GALERIA (COMPATÍVEL WEB/MOBILE)"),
                    const SizedBox(height: 30),
                    _buildMediaDropzone(),
                    const SizedBox(height: 60),
                    _buildHeader("3. DADOS COMERCIAIS E FINANCEIROS"),
                    const SizedBox(height: 40),
                    _buildTextField("Título da Oferta (ex: Miami Land 402)",
                        _titleCtrl, Icons.business),
                    const SizedBox(height: 25),
                    _buildTextField("Localização / County", _locationCtrl,
                        Icons.map_outlined),
                    const SizedBox(height: 25),
                    Row(children: [
                      Expanded(
                          child: _buildTextField(
                              "ROI Est. %", _roiCtrl, Icons.trending_up,
                              k: TextInputType.number)),
                      const SizedBox(width: 25),
                      Expanded(
                          child: _buildTextField(
                              "Valor USD", _priceCtrl, Icons.monetization_on,
                              k: TextInputType.number)),
                    ]),
                    const SizedBox(height: 60),
                    _buildHeader("4. ESPECIFICAÇÕES ($_activeType)"),
                    const SizedBox(height: 40),
                    _buildDynamicFields(),
                    const SizedBox(height: 100),
                    _buildLaunchButton(),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
    );
  }

  // --- COMPONENTES DE DESIGN SYSTEM ---

  Widget _buildHeader(String t) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t,
          style: GoogleFonts.cinzel(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2)),
      const SizedBox(height: 10),
      Container(width: 60, height: 3, color: gold),
    ]);
  }

  Widget _buildAssetTypeSelector() {
    return Row(
        children: ["Terreno", "Casa", "Reforma"].map((t) {
      bool active = _activeType == t;
      return Expanded(
          child: InkWell(
              onTap: () => setState(() => _activeType = t),
              child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  decoration: BoxDecoration(
                      color:
                          active ? gold : Colors.white.withValues(alpha: 0.05),
                      border: Border.all(color: active ? gold : Colors.white10),
                      borderRadius: BorderRadius.circular(5)),
                  child: Center(
                      child: Text(t.toUpperCase(),
                          style: TextStyle(
                              color: active ? navy : Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5))))));
    }).toList());
  }

  Widget _buildMediaDropzone() {
    return Column(children: [
      InkWell(
          onTap: _pickMedia,
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(80),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  border: Border.all(
                      color: gold.withValues(alpha: 0.3),
                      style: BorderStyle.solid)),
              child: Column(children: [
                Icon(Icons.add_a_photo_outlined, color: gold, size: 50),
                const SizedBox(height: 20),
                Text("ADICIONAR MÍDIAS DO ATIVO",
                    style: TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                        fontWeight: FontWeight.bold))
              ]))),
      if (_queuedMedia.isNotEmpty)
        Container(
            height: 160,
            margin: const EdgeInsets.only(top: 30),
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _queuedMedia.length,
                itemBuilder: (context, index) => Stack(children: [
                      Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(_queuedMedia[index].path),
                                  fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.white10))),
                      Positioned(
                          top: 8,
                          right: 28,
                          child: GestureDetector(
                              onTap: () =>
                                  setState(() => _queuedMedia.removeAt(index)),
                              child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Colors.white))))
                    ]))),
    ]);
  }

  Widget _buildDynamicFields() {
    if (_activeType == "Terreno")
      return _buildTextField(
          "Área do Lote (Sqft / Acres)", _areaCtrl, Icons.landscape);
    if (_activeType == "Casa")
      return Column(children: [
        _buildTextField("Living Area (Sqft)", _areaCtrl, Icons.straighten),
        const SizedBox(height: 25),
        _buildTextField("Quartos / Suítes", _roomCtrl, Icons.bed)
      ]);
    return Column(children: [
      _buildTextField("Budget Previsto USD", _renovBudgetCtrl, Icons.handyman,
          k: TextInputType.number),
      const SizedBox(height: 25),
      _buildTextField("Cronograma (Meses)", _deadlineCtrl, Icons.av_timer)
    ]);
  }

  Widget _buildTextField(String l, TextEditingController c, IconData i,
      {TextInputType k = TextInputType.text}) {
    return TextFormField(
        controller: c,
        keyboardType: k,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        validator: (v) => v!.isEmpty ? "Este campo é mandatório." : null,
        decoration: InputDecoration(
            labelText: l,
            labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
            prefixIcon: Icon(i, color: gold, size: 22),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white10)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: gold)),
            contentPadding: const EdgeInsets.all(25)));
  }

  Widget _buildLaunchButton() {
    return SizedBox(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
            onPressed: _executarAnuncioAtivo,
            style: ElevatedButton.styleFrom(
                backgroundColor: gold, foregroundColor: navy, elevation: 30),
            child: Text("DISTRIBUIR INVESTIMENTO PARA COTISTAS PRIVATE",
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 14))));
  }
}
