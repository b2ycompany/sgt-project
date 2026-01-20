import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Módulo de Assinatura Digital e Compliance SGT
/// Este ecrã é o portal de segurança onde o investidor oficializa sua entrada.
class AssinaturaDocumentoScreen extends StatefulWidget {
  const AssinaturaDocumentoScreen({super.key});

  @override
  State<AssinaturaDocumentoScreen> createState() =>
      _AssinaturaDocumentoScreenState();
}

class _AssinaturaDocumentoScreenState extends State<AssinaturaDocumentoScreen> {
  // Configuração Estética Private Banking
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color alertRed = const Color(0xFFC62828);

  // Estados de Controle do Fluxo
  bool _termosLidos = false;
  bool _isAssinando = false;
  bool _confirmacaoManual = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Monitora o scroll para garantir que o investidor leu o contrato até o fim
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!_termosLidos) {
          setState(() {
            _termosLidos = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Função para gravar a assinatura e o timestamp no Firestore
  Future<void> _processarAssinatura() async {
    setState(() => _isAssinando = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .update({
          'assinatura_digital_status': 'confirmado',
          'data_assinatura': FieldValue.serverTimestamp(),
          'ip_assinatura': 'Logado via Mobile App',
          'documento_versao': '2026.1.B',
        });

        if (mounted) {
          _mostrarSucesso();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erro no servidor de assinatura: $e"),
              backgroundColor: alertRed),
        );
      } finally {
        if (mounted) setState(() => _isAssinando = false);
      }
    }
  }

  void _mostrarSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: navy,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text("VALIDADO",
              style:
                  GoogleFonts.cinzel(color: gold, fontWeight: FontWeight.bold)),
          content: const Text(
            "Sua assinatura digital foi registrada com sucesso sob os protocolos de segurança CIG.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("IR PARA O DASHBOARD"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: _buildSimpleAppBar(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            _buildHeaderSection(),
            const SizedBox(height: 40),

            // CONTRATO LEGAL (Área de Scroll Intensa)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(30),
                    children: [
                      _buildContractText(),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            _buildInteractionControls(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- SUBCOMPONENTES DE UI ---

  PreferredSizeWidget _buildSimpleAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold),
      title: Text("COMPLIANCE PORTAL",
          style:
              GoogleFonts.cinzel(color: gold, fontSize: 12, letterSpacing: 2)),
      centerTitle: true,
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("DOCUMENTO DE ADESÃO",
            style: GoogleFonts.cinzel(
                color: gold,
                fontSize: 10,
                letterSpacing: 3,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("TERMO DE INVESTIMENTO PRIVATE",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text(
          "Para liberar sua participação nos lotes USA, revise e assine o termo de responsabilidade e ciência de risco.",
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildContractText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _contractHeading("CLÁUSULA 1: OBJETO DO INVESTIMENTO"),
        _contractBody(
            "A CIG Private Investment Group atua na inteligência de dados para aquisição de ativos imobiliários em território norte-americano, visando a valorização de capital sob a jurisdição do estado da Flórida e outros estados de alta liquidez."),
        _contractHeading("CLÁUSULA 2: RISCOS E VOLATILIDADE"),
        _contractBody(
            "O investidor declara estar ciente de que o mercado imobiliário, embora sólido, está sujeito a variações macroeconômicas. A performance passada não garante lucros futuros, embora o algoritmo SGT mantenha um histórico de 24.8% a.a."),
        _contractHeading("CLÁUSULA 3: PROTEÇÃO PATRIMONIAL"),
        _contractBody(
            "Os ativos são registrados sob a estrutura legal da SGT, garantindo que o capital do investidor esteja lastreado em terra (Land Assets), minimizando riscos de liquidez total em cenários de crise financeira bancária."),
        _contractHeading("CLÁUSULA 4: CONFIDENCIALIDADE"),
        _contractBody(
            "As oportunidades off-market apresentadas neste portal são estritamente confidenciais. A divulgação de lances ou localizações de lotes para terceiros resultará na exclusão imediata do grupo private e sanções contratuais."),
        _contractHeading("CLÁUSULA 5: TAXAS E PERFORMANCE"),
        _contractBody(
            "O grupo retém uma taxa de administração de 2% sobre o AUM e uma taxa de performance de 20% sobre o lucro excedente (Hurdle Rate), garantindo o alinhamento de interesses entre o gestor e o investidor."),
        const SizedBox(height: 50),
        const Center(
          child: Text("FIM DO DOCUMENTO - VERSÃO 2026-B",
              style: TextStyle(color: Colors.white12, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _contractHeading(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 10),
      child: Text(text,
          style: GoogleFonts.cinzel(
              color: gold, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _contractBody(String text) {
    return Text(text,
        style:
            const TextStyle(color: Colors.white60, fontSize: 13, height: 1.6));
  }

  Widget _buildInteractionControls() {
    return Column(
      children: [
        // Checkbox Estilizado
        InkWell(
          onTap: () {
            if (_termosLidos) {
              setState(() => _confirmacaoManual = !_confirmacaoManual);
            }
          },
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border:
                      Border.all(color: _termosLidos ? gold : Colors.white10),
                  color: _confirmacaoManual ? gold : Colors.transparent,
                ),
                child: _confirmacaoManual
                    ? const Icon(Icons.check, size: 14, color: Colors.black)
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  _termosLidos
                      ? "Declaro que li e aceito todas as condições do termo private."
                      : "Por favor, role o contrato até o fim para liberar a assinatura.",
                  style: TextStyle(
                      color: _termosLidos ? Colors.white70 : Colors.white24,
                      fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Botão de Assinatura (Trigger Final)
        SizedBox(
          width: double.infinity,
          height: 65,
          child: ElevatedButton(
            onPressed: (_termosLidos && _confirmacaoManual && !_isAssinando)
                ? _processarAssinatura
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: gold,
              foregroundColor: navy,
              disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
            ),
            child: _isAssinando
                ? const CircularProgressIndicator(color: Colors.black)
                : const Text("ASSINAR DIGITALMENTE AGORA"),
          ),
        ),
      ],
    );
  }
}
