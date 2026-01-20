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

  // --- CONTROLADORES DE DADOS (DADOS PESSOAIS E CONTATO) ---
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _profissaoController = TextEditingController();

  // --- ESTADOS DO PERFIL DO INVESTIDOR (SUITABILITY) ---
  String _perfilRisco = "Moderado";
  String _horizonteInvestimento = "Curto Prazo (até 2 anos)";
  String _experienciaInvestimento = "Iniciante";
  String _faixaPatrimonial = "Até \$100k";
  String _origemLead = "Indicação";

  // Cores Institucionais
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);

  @override
  void dispose() {
    _pageController.dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    _profissaoController.dispose();
    super.dispose();
  }

  // Função para salvar o dossiê completo no Firestore e mudar o status para 'pendente'
  Future<void> _finalizarOnboarding() async {
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

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
          'perfil_investidor': _perfilRisco,
          'horizonte_investimento': _horizonteInvestimento,
          'experiencia': _experienciaInvestimento,
          'faixa_patrimonial': _faixaPatrimonial,
          'origem_lead': _origemLead,
          'status': 'pendente', // Gatilho para o AdminDashboard
          'cargo': 'cliente',
          'capital_investido': 0.0,
          'data_solicitacao': FieldValue.serverTimestamp(),
          'biografia_onboarding':
              'Lead identificado via Discovery Progressivo.',
        });
        // O AuthWrapper no main.dart detectará a criação do doc e levará à tela de espera.
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro ao salvar perfil: $e"),
              backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  void _nextPage() {
    if (_currentStep < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic);
      setState(() => _currentStep++);
    } else {
      _finalizarOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _stepIdentificacao(),
                  _stepPatrimonio(),
                  _stepDiscovery(),
                  _stepRevisao(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- ETAPA 1: IDENTIFICAÇÃO PESSOAL ---
  Widget _stepIdentificacao() {
    return _baseStepLayout(
      title: "IDENTIFICAÇÃO",
      subtitle: "Para quem estamos desenhando esta estratégia?",
      content: [
        _buildTextField("Nome Completo", _nomeController, Icons.person_outline),
        const SizedBox(height: 20),
        _buildTextField("WhatsApp / Telefone", _telefoneController,
            Icons.phone_android_outlined,
            keyboard: TextInputType.phone),
        const SizedBox(height: 20),
        _buildTextField(
            "Profissão / Atuação", _profissaoController, Icons.work_outline),
      ],
    );
  }

  // --- ETAPA 2: PERFIL FINANCEIRO ---
  Widget _stepPatrimonio() {
    return _baseStepLayout(
      title: "PATRIMÔNIO",
      subtitle: "Qual a escala do capital sob sua gestão?",
      content: [
        _buildLabel("Capital pretendido para alocação USA:"),
        _buildDropdown(
          value: _faixaPatrimonial,
          items: [
            "Até \$100k",
            "\$100k a \$500k",
            "\$500k a \$1M",
            "Acima de \$1M (Whale)"
          ],
          onChanged: (val) => setState(() => _faixaPatrimonial = val!),
        ),
        const SizedBox(height: 30),
        _buildLabel("Experiência em investimentos imobiliários:"),
        _buildDropdown(
          value: _experienciaInvestimento,
          items: ["Iniciante", "Intermediário", "Expert / Profissional"],
          onChanged: (val) => setState(() => _experienciaInvestimento = val!),
        ),
      ],
    );
  }

  // --- ETAPA 3: DISCOVERY & RISK (SUITABILITY) ---
  Widget _stepDiscovery() {
    return _baseStepLayout(
      title: "ESTRATÉGIA",
      subtitle: "Como você prefere ver seu patrimônio crescer?",
      content: [
        _buildLabel("Perfil de tolerância a risco:"),
        _buildDropdown(
          value: _perfilRisco,
          items: [
            "Conservador (Proteção)",
            "Moderado (Equilíbrio)",
            "Agressivo (Máxima Valorização)"
          ],
          onChanged: (val) => setState(() => _perfilRisco = val!),
        ),
        const SizedBox(height: 30),
        _buildLabel("Como nos conheceu? (Discovery)"),
        _buildDropdown(
          value: _origemLead,
          items: [
            "Indicação",
            "Instagram / Redes Sociais",
            "Evento Presencial",
            "Anúncio Web"
          ],
          onChanged: (val) => setState(() => _origemLead = val!),
        ),
      ],
    );
  }

  // --- ETAPA 4: REVISÃO E ENVIO ---
  Widget _stepRevisao() {
    return _baseStepLayout(
      title: "REVISÃO",
      subtitle: "Confirme seus dados antes de enviar para análise.",
      content: [
        _reviewItem("INVESTIDOR", _nomeController.text),
        _reviewItem("PERFIL", _perfilRisco),
        _reviewItem("CAPITAL PREVISTO", _faixaPatrimonial),
        const SizedBox(height: 40),
        const Text(
          "Ao clicar em finalizar, seus dados serão auditados por nossa equipe de compliance para liberação do portal private.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white24, fontSize: 11),
        ),
      ],
    );
  }

  // --- COMPONENTES DE INTERFACE CUSTOMIZADOS ---

  Widget _baseStepLayout(
      {required String title,
      required String subtitle,
      required List<Widget> content}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.cinzel(
                  color: gold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3)),
          const SizedBox(height: 10),
          Text(subtitle,
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          ...content,
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextPage,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Color(0xFF050F22))
                  : Text(_currentStep == 3
                      ? "FINALIZAR SOLICITAÇÃO"
                      : "PRÓXIMO PASSO →"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep ? gold : Colors.white10,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: gold, size: 20),
      ),
    );
  }

  Widget _buildDropdown(
      {required String value,
      required List<String> items,
      required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: navy,
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _reviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
