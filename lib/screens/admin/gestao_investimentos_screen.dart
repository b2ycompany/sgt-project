import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class GestaoInvestimentosScreen extends StatefulWidget {
  const GestaoInvestimentosScreen({super.key});

  @override
  State<GestaoInvestimentosScreen> createState() =>
      _GestaoInvestimentosScreenState();
}

class _GestaoInvestimentosScreenState extends State<GestaoInvestimentosScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores do Formulário de Oferta
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _roiController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _imgUrlController = TextEditingController();

  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);

  @override
  void dispose() {
    _tituloController.dispose();
    _localController.dispose();
    _roiController.dispose();
    _precoController.dispose();
    _imgUrlController.dispose();
    super.dispose();
  }

  Future<void> _criarOferta() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('ofertas').add({
          'titulo': _tituloController.text.trim(),
          'localizacao': _localController.text.trim(),
          'roi_estimado': _roiController.text.trim(),
          'preco_lote': _precoController.text.trim(),
          'imagem_url': _imgUrlController.text.trim(),
          'data_criacao': FieldValue.serverTimestamp(),
          'status': 'ativo',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Nova Oferta lançada no mercado!")),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        debugPrint("Erro ao criar oferta: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("LANÇAR NOVA OFERTA SGT",
            style: GoogleFonts.cinzel(
                color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("DETALHES DO ATIVO",
                  style: GoogleFonts.cinzel(color: Colors.white, fontSize: 20)),
              const SizedBox(height: 30),
              _buildField("Título da Oferta (ex: Lote 442 North Florida)",
                  _tituloController, Icons.title),
              const SizedBox(height: 20),
              _buildField(
                  "Localização Exata", _localController, Icons.location_on),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                      child: _buildField("ROI Estimado (% a.a.)",
                          _roiController, Icons.trending_up,
                          keyboard: TextInputType.number)),
                  const SizedBox(width: 20),
                  Expanded(
                      child: _buildField("Preço Total (USD)", _precoController,
                          Icons.attach_money,
                          keyboard: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              _buildField("Link da Imagem do Terreno", _imgUrlController,
                  Icons.image_search),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _criarOferta,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: gold, foregroundColor: navy),
                  child: const Text("PUBLICAR INVESTIMENTO PARA COTISTAS",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      validator: (value) =>
          value == null || value.isEmpty ? "Campo obrigatório" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: gold),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold)),
      ),
    );
  }
}
