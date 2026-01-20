import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Certifique-se de rodar 'flutter pub add intl'

/// Módulo de Gestão de Fluxo de Capital CIG Private
/// Versão Corrigida: Implementa formatação de moeda e tratamento de erros de compilação.
class AportesTransferenciasScreen extends StatefulWidget {
  const AportesTransferenciasScreen({super.key});

  @override
  State<AportesTransferenciasScreen> createState() =>
      _AportesTransferenciasScreenState();
}

class _AportesTransferenciasScreenState
    extends State<AportesTransferenciasScreen> {
  // Configuração Visual de Elite baseada no Branding SGT
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);
  final Color errorColor = const Color(0xFFC62828);

  // Controladores de Estado e Formatação
  final TextEditingController _valorController = TextEditingController();
  final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'en_US', symbol: '\$ ', decimalDigits: 2);

  // Estados da Interface
  bool _isSubmitting = false;
  bool _comprovanteAnexado = false;
  final String _metodoSelecionado =
      "Wire Transfer (International)"; // Definido como final para evitar diagnóstico

  @override
  void initState() {
    super.initState();
    // Inicia o campo com valor zero formatado
    _valorController.text = _currencyFormat.format(0.0);
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  // Máscara de entrada para Dólar em tempo real
  void _onAmountChanged(String value) {
    if (value.isEmpty) return;

    // Remove tudo que não for número
    String cleanValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    double doubleValue = double.parse(cleanValue) / 100;

    setState(() {
      _valorController.text = _currencyFormat.format(doubleValue);
    });
  }

  // Lógica de Submissão de Aporte ao Firestore
  Future<void> _declararAporte() async {
    // Validação de entrada
    double valorLimpo =
        double.parse(_valorController.text.replaceAll(RegExp(r'[^0-9.]'), ''));

    if (valorLimpo <= 0) {
      _notificarErro("Defina um valor válido para o aporte.");
      return;
    }

    if (!_comprovanteAnexado) {
      _notificarErro("O upload do comprovante é obrigatório para compliance.");
      return;
    }

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Registro da transação para auditoria do Administrador
        await FirebaseFirestore.instance.collection('transacoes').add({
          'investidor_uid': user.uid,
          'email': user.email,
          'valor': valorLimpo,
          'tipo': 'aporte',
          'metodo': _metodoSelecionado,
          'status': 'pendente', // Gatilho para o AdminDashboard
          'data_declaracao': FieldValue.serverTimestamp(),
          'protocolo_transacao': 'SGT-${DateTime.now().millisecondsSinceEpoch}',
          'comprovante_validado': false,
        });

        if (mounted) _mostrarSucesso();
      } catch (e) {
        _notificarErro("Falha crítica no cofre de dados: $e");
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  void _notificarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarSucesso() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: AlertDialog(
          backgroundColor: navy,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text("SOLICITAÇÃO REGISTRADA",
              style: GoogleFonts.cinzel(
                  color: gold, fontWeight: FontWeight.bold, fontSize: 18)),
          content: Text(
            "Sua declaração de aporte foi encaminhada para a mesa de operações da CIG Private. O saldo em conta será atualizado após a liquidação bancária.",
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Retorna ao Dashboard
              },
              child: const Text("CONCLUIR"),
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
      appBar: _buildCustomAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstructionHeader(),
            const SizedBox(height: 45),

            // --- ENTRADA DE CAPITAL ---
            _buildAmountInputSection(),
            const SizedBox(height: 40),

            // --- INFORMAÇÕES DE LIQUIDAÇÃO (BANKING) ---
            _buildBankingDetailsFrame(),
            const SizedBox(height: 45),

            // --- ÁREA DE COMPLIANCE (UPLOAD) ---
            _buildComplianceUploadArea(),
            const SizedBox(height: 55),

            // --- AÇÃO FINAL ---
            _buildSubmitButton(),
            const SizedBox(height: 70),

            _buildBottomDisclaimer(),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DE INTERFACE (DETALHADOS) ---

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      backgroundColor: navy,
      elevation: 0,
      iconTheme: IconThemeData(color: gold),
      title: Text("TRANSFERÊNCIA DE FUNDOS",
          style: GoogleFonts.cinzel(
              color: gold,
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.bold)),
      centerTitle: true,
    );
  }

  Widget _buildInstructionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CIG ASSET MANAGEMENT",
            style: GoogleFonts.poppins(
                color: gold.withOpacity(0.5),
                fontSize: 9,
                letterSpacing: 3,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text("DECLARAR APORTE",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text(
          "Para conciliação do seu capital investido, realize a transferência bancária e anexe o comprovante oficial abaixo.",
          style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildAmountInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("VALOR DO INVESTIMENTO (USD)",
            style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 15),
        TextField(
          controller: _valorController,
          onChanged: _onAmountChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: GoogleFonts.robotoMono(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon:
                Icon(Icons.monetization_on_outlined, color: gold, size: 28),
            hintText: "\$ 0.00",
            contentPadding:
                const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.02),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
        ),
      ],
    );
  }

  Widget _buildBankingDetailsFrame() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_outlined, color: gold, size: 20),
              const SizedBox(width: 15),
              Text("COORDENADAS BANCÁRIAS INTERNACIONAIS",
                  style: GoogleFonts.cinzel(
                      color: gold, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          _bankField("Beneficiário", "CIG PRIVATE GROUP LLC"),
          _bankField("Banco", "JPMORGAN CHASE BANK, N.A."),
          _bankField("SWIFT/BIC", "CHASUS33XXX"),
          _bankField("Account Number", "9988220011-5"),
          _bankField("Moeda", "USD (United States Dollar)"),
          const SizedBox(height: 25),
          const Divider(color: Colors.white10),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.info_outline, color: gold.withOpacity(0.5), size: 14),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "A transferência deve ser realizada via mesma titularidade do investidor cadastrado.",
                  style: TextStyle(
                      color: Colors.white24,
                      fontSize: 9,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bankField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white24, fontSize: 11)),
          Text(value,
              style: GoogleFonts.robotoMono(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildComplianceUploadArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DOCUMENTAÇÃO DE COMPROVAÇÃO",
            style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1)),
        const SizedBox(height: 15),
        InkWell(
          onTap: () {
            // Simulação de Seleção de Arquivo
            setState(() => _comprovanteAnexado = true);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: BoxDecoration(
              color: _comprovanteAnexado
                  ? emerald.withOpacity(0.05)
                  : Colors.white.withOpacity(0.01),
              border: Border.all(
                  color: _comprovanteAnexado
                      ? emerald
                      : Colors.white.withOpacity(0.1),
                  style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(
                    _comprovanteAnexado
                        ? Icons.task_alt_rounded
                        : Icons.file_upload_outlined,
                    color: _comprovanteAnexado ? emerald : gold,
                    size: 35),
                const SizedBox(height: 15),
                Text(
                  _comprovanteAnexado
                      ? "COMPROVANTE ANEXADO COM SUCESSO"
                      : "CLIQUE PARA SELECIONAR COMPROVANTE",
                  style: TextStyle(
                      color: _comprovanteAnexado ? emerald : Colors.white24,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _declararAporte,
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: navy,
          elevation: 15,
          shadowColor: gold.withOpacity(0.3),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Color(0xFF050F22))
            : Text("CONFIRMAR DECLARAÇÃO DE APORTE",
                style: GoogleFonts.cinzel(
                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildBottomDisclaimer() {
    return Center(
      child: Column(
        children: [
          const Text("ESTE PORTAL UTILIZA CRIPTOGRAFIA DE 256 BITS",
              style: TextStyle(
                  color: Colors.white10, fontSize: 8, letterSpacing: 2)),
          const SizedBox(height: 15),
          Icon(Icons.security_outlined,
              color: Colors.white.withOpacity(0.05), size: 20),
        ],
      ),
    );
  }
}
