import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Onboarding Discovery v2.0 - Responsivo e Imersivo
/// Focado em identificar o perfil do investidor Leonardo e gerar o protocolo de fila.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // --- CONTROLADORES DE DADOS (KYC & DISCOVERY) ---
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();
  final TextEditingController _objetivoController = TextEditingController();

  // --- ESTADOS DE PERFIL ---
  String _perfilInvestidor = "Moderado";
  String _faixaPatrimonial = "Até \$100k";
  String _origemLead = "Instagram";
  String _objetivoInvestimento = "Proteção Patrimonial";

  // --- PALETA DE LUXO CIG ---
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  // --- ANIMAÇÕES DE EFEITO ---
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _profissaoController.dispose();
    _objetivoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // GERAÇÃO DE PROTOCOLO DE FILA
  String _generateQueueNumber() {
    return (Random().nextInt(8999) + 1000).toString();
  }

  // SALVAMENTO ATÔMICO NO FIRESTORE
  Future<void> _finalizarDiscovery() async {
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
          'email': user.email ?? "",
          'nome': _nomeController.text.trim(),
          'telefone': _telefoneController.text.trim(),
          'profissao': _profissaoController.text.trim(),
          'perfil_investidor': _perfilInvestidor,
          'faixa_patrimonial': _faixaPatrimonial,
          'objetivo': _objetivoInvestimento,
          'origem_lead': _origemLead,
          'numero_fila': protocol,
          'status': 'pendente',
          'cargo': 'cliente',
          'data_solicitacao': FieldValue.serverTimestamp(),
        });
        // O AuthWrapper cuidará de mostrar a tela de espera.
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro de Sincronia: $e"),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _fadeController.reverse().then((_) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic);
        setState(() => _currentStep++);
        _fadeController.forward();
      });
    } else {
      _finalizarDiscovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth =
              constraints.maxWidth > 600 ? 550 : constraints.maxWidth;
          return Stack(
            children: [
              _buildBackgroundEffect(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Container(
                    width: maxWidth,
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight * 0.8),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildProgressIndicator(),
                          const SizedBox(height: 50),
                          SizedBox(
                            height:
                                450, // Altura fixa controlada para o PageView
                            child: PageView(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _stepIdentity(),
                                _stepFinance(),
                                _stepStrategy(),
                                _stepReview(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- PASSOS DO FLUXO (SEM ABREVIAÇÕES) ---

  Widget _stepIdentity() {
    return _baseStepLayout(
      title: "IDENTIDADE",
      subtitle: "Como devemos chamar você no portal private?",
      content: [
        _buildTextField("Nome Completo", _nomeController, Icons.person_outline),
        const SizedBox(height: 20),
        _buildTextField("WhatsApp de Contato", _telefoneController,
            Icons.phone_android_outlined,
            keyboard: TextInputType.phone),
        const SizedBox(height: 20),
        _buildTextField("Profissão / Cargo Atual", _profissaoController,
            Icons.business_center_outlined),
      ],
    );
  }

  Widget _stepFinance() {
    return _baseStepLayout(
      title: "CAPITAL",
      subtitle: "Qual sua disponibilidade para alocação USA?",
      content: [
        _buildLabel("Faixa patrimonial pretendida:"),
        _buildDropdown(
          _faixaPatrimonial,
          [
            "Até \$100k",
            "\$100k a \$500k",
            "\$500k a \$1M",
            "Acima de \$1M (Whale)"
          ],
          (v) => setState(() => _faixaPatrimonial = v!),
        ),
        const SizedBox(height: 30),
        _buildLabel("De onde nos conheceu? (Lead Discovery)"),
        _buildDropdown(
          _origemLead,
          [
            "Instagram",
            "Indicação de Membro",
            "Evento Presencial",
            "YouTube / Web"
          ],
          (v) => setState(() => _origemLead = v!),
        ),
      ],
    );
  }

  Widget _stepStrategy() {
    return _baseStepLayout(
      title: "ESTRATÉGIA",
      subtitle: "Defina seus objetivos de rentabilidade.",
      content: [
        _buildLabel("Perfil de risco aceitável:"),
        _buildDropdown(
          _perfilInvestidor,
          ["Conservador", "Moderado", "Agressivo"],
          (v) => setState(() => _perfilInvestidor = v!),
        ),
        const SizedBox(height: 30),
        _buildLabel("Objetivo principal com a CIG:"),
        _buildDropdown(
          _objetivoInvestimento,
          [
            "Proteção Patrimonial",
            "Valorização Imobiliária",
            "Renda Passiva em Dólar"
          ],
          (v) => setState(() => _objetivoInvestimento = v!),
        ),
      ],
    );
  }

  Widget _stepReview() {
    return _baseStepLayout(
      title: "CONFIRMAÇÃO",
      subtitle: "Verifique os dados do seu Discovery.",
      content: [
        _reviewRow(
            "INVESTIDOR",
            _nomeController.text.isEmpty
                ? "Não informado"
                : _nomeController.text),
        _reviewRow("TELEFONE", _telefoneController.text),
        _reviewRow("PERFIL", _perfilInvestidor),
        _reviewRow("CAPITAL", _faixaPatrimonial),
        const SizedBox(height: 30),
        const Text(
          "Ao prosseguir, seus dados serão auditados para geração do protocolo de fila única CIG Private.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white24, fontSize: 10, height: 1.5),
        ),
      ],
    );
  }

  // --- COMPONENTES DE UI CUSTOMIZADOS ---

  Widget _baseStepLayout(
      {required String title,
      required String subtitle,
      required List<Widget> content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 4)),
        const SizedBox(height: 10),
        Text(subtitle,
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 40),
        ...content,
      ],
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: gold, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: navy,
        icon: Icon(Icons.keyboard_arrow_down, color: gold),
        items: items
            .map((e) => DropdownMenuItem(
                value: e,
                child: Text(e,
                    style: const TextStyle(color: Colors.white, fontSize: 14))))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 65,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: navy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const CircularProgressIndicator(color: Colors.black)
                : Text(_currentStep == 3 ? "SOLICITAR ACESSO" : "PRÓXIMO PASSO",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        if (_currentStep > 0)
          TextButton(
            onPressed: () {
              _pageController.previousPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
              setState(() => _currentStep--);
            },
            child: Text("VOLTAR",
                style: TextStyle(
                    color: Colors.white38, fontSize: 12, letterSpacing: 2)),
          ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? gold
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(2),
              boxShadow: index <= _currentStep
                  ? [
                      BoxShadow(
                          color: gold.withValues(alpha: 0.3), blurRadius: 10)
                    ]
                  : [],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBackgroundEffect() {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.05,
        child: CustomPaint(painter: ParticleOnboardingPainter()),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 5),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1)),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

// Pintor de Efeitos de Partícula para Background
class ParticleOnboardingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.2);
    final random = Random(42);
    for (var i = 0; i < 30; i++) {
      canvas.drawCircle(
          Offset(random.nextDouble() * size.width,
              random.nextDouble() * size.height),
          random.nextDouble() * 2,
          paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
