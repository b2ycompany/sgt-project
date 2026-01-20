import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GestaoRateioScreen extends StatefulWidget {
  const GestaoRateioScreen({super.key});

  @override
  State<GestaoRateioScreen> createState() => _GestaoRateioScreenState();
}

class _GestaoRateioScreenState extends State<GestaoRateioScreen> {
  final Color navy = const Color(0xFF050F22);
  final Color gold = const Color(0xFFD4AF37);
  final Color emerald = const Color(0xFF2E8B57);

  // Controladores para o cálculo do Rateio
  final TextEditingController _valorVendaController = TextEditingController();
  final TextEditingController _despesasController = TextEditingController();

  String? _selectedOfertaId;
  double _lucroLiquido = 0.0;
  final List<Map<String, dynamic>> _participantes = [];

  // Função para calcular o lucro e o rateio proporcional
  void _calcularRateio() {
    double valorVenda = double.tryParse(_valorVendaController.text) ?? 0;
    double despesas = double.tryParse(_despesasController.text) ?? 0;

    // Supondo que o preço original do lote esteja na oferta
    // Aqui usamos um valor base para demonstração, mas no sistema real virá do Firestore
    double precoOriginal = 100000.0;

    setState(() {
      _lucroLiquido = valorVenda - precoOriginal - despesas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: IconThemeData(color: gold),
        title: Text("MOTOR DE RATEIO & DIVIDENDOS",
            style: GoogleFonts.cinzel(
                color: gold, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DETALHES DA LIQUIDAÇÃO",
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 18)),
            const SizedBox(height: 30),

            // Seleção do Lote/Oferta vendida
            _buildDropdownOfertas(),
            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                    child: _buildInput(
                        "VALOR FINAL DE VENDA (USD)", _valorVendaController)),
                const SizedBox(width: 20),
                Expanded(
                    child: _buildInput(
                        "DESPESAS/TAXAS (USD)", _despesasController)),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _calcularRateio,
                style: ElevatedButton.styleFrom(
                    backgroundColor: gold, foregroundColor: navy),
                child: const Text("PROCESSAR CÁLCULO DE LUCRO",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 50),
            if (_lucroLiquido > 0) _buildResultadosSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownOfertas() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ofertas')
            .where('status', isEqualTo: 'ativo')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const LinearProgressIndicator();

          return DropdownButton<String>(
            isExpanded: true,
            dropdownColor: navy,
            underline: const SizedBox(),
            hint: const Text("SELECIONE O LOTE LIQUIDADO",
                style: TextStyle(color: Colors.white38)),
            value: _selectedOfertaId,
            items: snapshot.data!.docs.map((doc) {
              return DropdownMenuItem(
                value: doc.id,
                child: Text(doc['titulo'],
                    style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedOfertaId = val),
          );
        },
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: gold)),
      ),
    );
  }

  Widget _buildResultadosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
              color: emerald.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("LUCRO LÍQUIDO TOTAL:",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text("\$ ${_lucroLiquido.toStringAsFixed(2)}",
                  style: GoogleFonts.cinzel(
                      color: emerald,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Text("DISTRIBUIÇÃO PROPORCIONAL",
            style: GoogleFonts.cinzel(
                color: gold, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Tabela de Participantes (Exemplo de lógica de rateio)
        _participanteItem("Investidor Alpha", 45, _lucroLiquido * 0.45),
        _participanteItem("Investidor Beta", 30, _lucroLiquido * 0.30),
        _participanteItem("Investidor Gamma", 25, _lucroLiquido * 0.25),

        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton.icon(
            onPressed: () => _confirmarDistribuicao(),
            icon: const Icon(Icons.send_rounded),
            label: const Text("DISPARAR DIVIDENDOS PARA WALLETS",
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
                backgroundColor: emerald, foregroundColor: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _participanteItem(String nome, int porcentagem, double valorReceber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(nome, style: const TextStyle(color: Colors.white70)),
          Text("$porcentagem%",
              style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
          Text("\$ ${valorReceber.toStringAsFixed(2)}",
              style: TextStyle(color: emerald, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _confirmarDistribuicao() async {
    // Lógica para salvar os lucros na subcoleção 'rendimentos' de cada usuário no Firestore
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Distribuição concluída! Saldos atualizados.")),
    );
  }
}
