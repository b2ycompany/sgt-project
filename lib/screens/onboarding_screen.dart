import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // CONTROLADORES E DADOS
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();

  String _perfilInvestidor = "Moderado";
  String _faixaPatrimonial = "De \$100k a \$500k";
  String _objetivo = "Proteção Patrimonial";
  String _origem = "Instagram";

  final Color gold = const Color(0xFFD4AF37);
  final Color navy = const Color(0xFF050F22);

  String _generateQueueNumber() {
    return (Random().nextInt(8999) + 1000).toString();
  }

  Future<void> _finalizarOnboarding() async {
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    final protocol = _generateQueueNumber();

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'email': user.email,
          'nome': _nomeController.text.trim(),
          'telefone': _telefoneController.text.trim(),
          'profissao': _profissaoController.text.trim(),
          'perfil_investidor': _perfilInvestidor,
          'faixa_patrimonial': _faixaPatrimonial,
          'objetivo': _objetivo,
          'origem_lead': _origem,
          'numero_fila': protocol,
          'status': 'pendente',
          'cargo': 'cliente',
          'data_solicitacao': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
      }
    }
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutExpo);
      setState(() => _currentStep++);
    } else {
      _finalizarOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          _buildBackgroundEffect(),
          SafeArea(
            child: Column(
              children: [
                _buildProgressHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _stepIdentity(),
                      _stepFinancial(),
                      _stepSuitability(),
                      _stepFinalReview(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffect() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: Image.network(
          "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Row(
        children: List.generate(
            4,
            (index) => Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                        color: index <= _currentStep ? gold : Colors.white10),
                  ),
                )),
      ),
    );
  }

  Widget _layoutStep(
      {required String title,
      required String sub,
      required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.cinzel(
                  color: gold,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(sub,
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          ...children,
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextPage,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : Text(
                      _currentStep == 3 ? "SUBMETER PROTOCOLO" : "CONTINUAR →"),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _stepIdentity() {
    return _layoutStep(
      title: "Discovery: Passo 01",
      sub: "Quem é o investidor?",
      children: [
        _buildTextField("Nome Completo", _nomeController, Icons.person_outline),
        const SizedBox(height: 25),
        _buildTextField("WhatsApp", _telefoneController, Icons.phone_outlined,
            keyboard: TextInputType.phone),
        const SizedBox(height: 25),
        _buildTextField(
            "Profissão Principal", _profissaoController, Icons.work_outline),
      ],
    );
  }

  Widget _stepFinancial() {
    return _layoutStep(
      title: "Discovery: Passo 02",
      sub: "Capacidade de Alocação",
      children: [
        _buildLabel("Faixa de patrimônio disponível para USA:"),
        _buildDropdown(
            _faixaPatrimonial,
            [
              "Até \$100k",
              "De \$100k a \$500k",
              "De \$500k a \$1M",
              "Acima de \$1M"
            ],
            (v) => setState(() => _faixaPatrimonial = v!)),
        const SizedBox(height: 35),
        _buildLabel("De onde nos conhece?"),
        _buildDropdown(
            _origem,
            ["Instagram", "Indicação", "Evento Presencial", "YouTube"],
            (v) => setState(() => _origem = v!)),
      ],
    );
  }

  Widget _stepSuitability() {
    return _layoutStep(
      title: "Discovery: Passo 03",
      sub: "Perfil & Objetivos",
      children: [
        _buildLabel("Sua tolerância a risco:"),
        _buildDropdown(
            _perfilInvestidor,
            ["Conservador", "Moderado", "Agressivo"],
            (v) => setState(() => _perfilInvestidor = v!)),
        const SizedBox(height: 35),
        _buildLabel("Objetivo Principal no SGT:"),
        _buildDropdown(
            _objetivo,
            ["Proteção Patrimonial", "Valorização", "Renda Passiva"],
            (v) => setState(() => _objetivo = v!)),
      ],
    );
  }

  Widget _stepFinalReview() {
    return _layoutStep(
      title: "Discovery: Passo 04",
      sub: "Confirmação de Dados",
      children: [
        _reviewCard("INVESTIDOR", _nomeController.text),
        _reviewCard("CATEGORIA", _perfilInvestidor),
        _reviewCard("CAPITAL", _faixaPatrimonial),
        const SizedBox(height: 30),
        const Text(
            "Ao submeter, você entrará em nossa fila de análise private. Um consultor entrará em contato para validar seu acesso.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white24, fontSize: 11)),
      ],
    );
  }

  Widget _buildTextField(String l, TextEditingController c, IconData i,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration:
          InputDecoration(labelText: l, prefixIcon: Icon(i, color: gold)),
    );
  }

  Widget _buildDropdown(
      String val, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: val,
        isExpanded: true,
        dropdownColor: navy,
        underline: const SizedBox(),
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e, style: const TextStyle(color: Colors.white))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildLabel(String t) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
                fontWeight: FontWeight.bold)));
  }

  Widget _reviewCard(String l, String v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          Text(v,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
