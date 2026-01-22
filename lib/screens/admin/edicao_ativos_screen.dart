import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Módulo de Edição de Ativos v1.0 - CIG Private
/// Interface de alta densidade para manutenção de portfólio multi-ativos.
class EdicaoAtivosScreen extends StatefulWidget {
  final String assetId;
  final Map<String, dynamic> assetData;

  const EdicaoAtivosScreen(
      {super.key, required this.assetId, required this.assetData});

  @override
  State<EdicaoAtivosScreen> createState() => _EdicaoAtivosScreenState();
}

class _EdicaoAtivosScreenState extends State<EdicaoAtivosScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // --- ESTADO DO ATIVO ---
  late String _tipoAtivo;
  List<String> _urlsServidor = [];
  List<File> _novasImagensLocais = [];
  final ImagePicker _picker = ImagePicker();

  // --- CONTROLADORES TÉCNICOS ---
  late TextEditingController _tituloController;
  late TextEditingController _localController;
  late TextEditingController _roiController;
  late TextEditingController _precoController;

  // CONTROLADORES DE ESPECIFICAÇÃO
  late TextEditingController _metragemController;
  late TextEditingController _quartosController;
  late TextEditingController _custoReformaController;
  late TextEditingController _prazoObraController;

  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  @override
  void initState() {
    super.initState();
    _carregarDadosIniciais();
  }

  void _carregarDadosIniciais() {
    final data = widget.assetData;
    _tipoAtivo = data['tipo'] ?? "Terreno";
    _urlsServidor = List<String>.from(data['imagens_urls'] ?? []);

    _tituloController = TextEditingController(text: data['titulo']);
    _localController = TextEditingController(text: data['localizacao']);
    _roiController = TextEditingController(text: data['roi_estimado']);
    _precoController = TextEditingController(text: data['preco_lote']);

    final specs = data['especificacoes'] ?? {};
    _metragemController = TextEditingController(
        text: specs['area_acres'] ?? specs['living_area'] ?? "");
    _quartosController = TextEditingController(text: specs['rooms'] ?? "");
    _custoReformaController =
        TextEditingController(text: specs['budget_work'] ?? "");
    _prazoObraController =
        TextEditingController(text: specs['timeline_months'] ?? "");
  }

  @override
  void dispose() {
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

  // --- GESTÃO DE MÍDIA AVANÇADA ---
  Future<void> _adicionarFotos() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _novasImagensLocais.addAll(picked.map((e) => File(e.path)).toList());
        });
      }
    } catch (e) {
      _showToast("Erro ao carregar mídia: $e", isError: true);
    }
  }

  void _removerFotoServidor(int index) {
    setState(() => _urlsServidor.removeAt(index));
  }

  void _removerNovaFoto(int index) {
    setState(() => _novasImagensLocais.removeAt(index));
  }

  Future<List<String>> _uploadNovasFotos() async {
    List<String> uploadedUrls = [];
    for (int i = 0; i < _novasImagensLocais.length; i++) {
      final String fileName =
          "update_${DateTime.now().millisecondsSinceEpoch}_$i.jpg";
      final ref = FirebaseStorage.instance
          .ref()
          .child('ofertas/${widget.assetId}/$fileName');

      await ref.putFile(_novasImagensLocais[i]);
      uploadedUrls.add(await ref.getDownloadURL());
    }
    return uploadedUrls;
  }

  // --- SINCRONIZAÇÃO FIRESTORE ---
  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) return;

    if (_urlsServidor.isEmpty && _novasImagensLocais.isEmpty) {
      _showToast("O ativo deve possuir ao menos uma imagem representativa.",
          isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Processar novos uploads se existirem
      List<String> urlsFinais = [..._urlsServidor];
      if (_novasImagensLocais.isNotEmpty) {
        final novasUrls = await _uploadNovasFotos();
        urlsFinais.addAll(novasUrls);
      }

      // 2. Montar Payload de Atualização
      Map<String, dynamic> updateData = {
        'tipo': _tipoAtivo,
        'titulo': _tituloController.text.trim(),
        'localizacao': _localController.text.trim(),
        'roi_estimado': _roiController.text.trim(),
        'preco_lote': _precoController.text.trim(),
        'imagens_urls': urlsFinais,
        'ultima_edicao': FieldValue.serverTimestamp(),
        'especificacoes': {
          if (_tipoAtivo == "Terreno") 'area_acres': _metragemController.text,
          if (_tipoAtivo == "Casa") ...{
            'living_area': _metragemController.text,
            'rooms': _quartosController.text,
          },
          if (_tipoAtivo == "Reforma") ...{
            'budget_work': _custoReformaController.text,
            'timeline_months': _prazoObraController.text,
          }
        }
      };

      await FirebaseFirestore.instance
          .collection('ofertas')
          .doc(widget.assetId)
          .update(updateData);

      if (mounted) {
        _showToast("ATIVO ATUALIZADO: Sincronização concluída.");
        Navigator.pop(context);
      }
    } catch (e) {
      _showToast("Falha na atualização: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showToast(String msg, {bool isError = false}) {
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
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("MANUTENÇÃO DE ATIVO",
            style: GoogleFonts.cinzel(
                color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: _isSaving
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: gold),
                const SizedBox(height: 25),
                Text("SALVANDO ALTERAÇÕES...",
                    style: GoogleFonts.cinzel(color: gold, fontSize: 12))
              ],
            ))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("CLASSE DO INVESTIMENTO"),
                    const SizedBox(height: 20),
                    _buildTypeSelector(),
                    const SizedBox(height: 45),
                    _buildSectionLabel("GESTÃO DE GALERIA"),
                    const SizedBox(height: 25),
                    _buildCombinedGallery(),
                    const SizedBox(height: 20),
                    _buildAddMediaButton(),
                    const SizedBox(height: 50),
                    _buildSectionLabel("DADOS COMERCIAIS"),
                    const SizedBox(height: 30),
                    _buildField(
                        "Título da Oferta", _tituloController, Icons.title),
                    const SizedBox(height: 20),
                    _buildField("Localização (USA)", _localController,
                        Icons.location_on),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _buildField(
                                "ROI Est. %", _roiController, Icons.trending_up,
                                keyboard: TextInputType.number)),
                        const SizedBox(width: 20),
                        Expanded(
                            child: _buildField("Preço (USD)", _precoController,
                                Icons.monetization_on,
                                keyboard: TextInputType.number)),
                      ],
                    ),
                    const SizedBox(height: 45),
                    _buildSectionLabel("ESPECIFICAÇÕES TÉCNICAS"),
                    const SizedBox(height: 25),
                    _buildDynamicSpecs(),
                    const SizedBox(height: 80),
                    _buildActionButtons(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  // --- COMPONENTES DE INTERFACE CUSTOMIZADOS ---

  Widget _buildSectionLabel(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 2)),
        const SizedBox(height: 8),
        Container(width: 40, height: 2, color: gold),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Row(
      children: ["Terreno", "Casa", "Reforma"].map((type) {
        bool isSelected = _tipoAtivo == type;
        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _tipoAtivo = type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(
                color: isSelected ? gold : Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: isSelected ? gold : Colors.white10),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(type.toUpperCase(),
                    style: TextStyle(
                        color: isSelected ? navy : Colors.white60,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCombinedGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_urlsServidor.isNotEmpty) ...[
          const Text("IMAGENS ATIVAS NO PORTAL",
              style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _urlsServidor.length,
              itemBuilder: (context, index) => _imageThumbnail(
                  _urlsServidor[index], () => _removerFotoServidor(index),
                  isNetwork: true),
            ),
          ),
        ],
        if (_novasImagensLocais.isNotEmpty) ...[
          const SizedBox(height: 25),
          const Text("NOVAS MÍDIAS PARA UPLOAD",
              style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _novasImagensLocais.length,
              itemBuilder: (context, index) => _imageThumbnail(
                  _novasImagensLocais[index].path,
                  () => _removerNovaFoto(index),
                  isNetwork: false),
            ),
          ),
        ],
      ],
    );
  }

  Widget _imageThumbnail(String path, VoidCallback onRemove,
      {required bool isNetwork}) {
    return Stack(
      children: [
        Container(
          width: 110,
          margin: const EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: isNetwork
                  ? NetworkImage(path) as ImageProvider
                  : FileImage(File(path)),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white10),
          ),
        ),
        Positioned(
          top: 5,
          right: 20,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                  color: Colors.red, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildAddMediaButton() {
    return TextButton.icon(
      onPressed: _adicionarFotos,
      icon: Icon(Icons.add_a_photo_outlined, color: gold, size: 20),
      label: Text("ADICIONAR MAIS FOTOS",
          style: TextStyle(
              color: gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5)),
    );
  }

  Widget _buildDynamicSpecs() {
    if (_tipoAtivo == "Terreno") {
      return _buildField(
          "Área Total (Acres/Sqft)", _metragemController, Icons.landscape);
    } else if (_tipoAtivo == "Casa") {
      return Column(
        children: [
          _buildField(
              "Living Area (Sqft)", _metragemController, Icons.straighten),
          const SizedBox(height: 20),
          _buildField("Quartos / Banheiros", _quartosController, Icons.bed),
        ],
      );
    } else {
      return Column(
        children: [
          _buildField("Orçamento da Obra (USD)", _custoReformaController,
              Icons.handyman,
              keyboard: TextInputType.number),
          const SizedBox(height: 20),
          _buildField("Cronograma (Meses)", _prazoObraController, Icons.timer),
        ],
      );
    }
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      validator: (value) =>
          value == null || value.isEmpty ? "Campo obrigatório" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        prefixIcon: Icon(icon, color: gold, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 70,
          child: ElevatedButton(
            onPressed: _salvarAlteracoes,
            style: ElevatedButton.styleFrom(
                backgroundColor: gold, foregroundColor: navy),
            child: Text("CONFIRMAR ATUALIZAÇÃO DO ATIVO",
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("DESCARTAR ALTERAÇÕES",
              style: TextStyle(color: Colors.white24, fontSize: 11)),
        ),
      ],
    );
  }
}
