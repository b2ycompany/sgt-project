import 'package:flutter/material.dart';
import 'dart:math';

class GestaoFinanceiraScreen extends StatefulWidget {
  const GestaoFinanceiraScreen({super.key});

  @override
  State<GestaoFinanceiraScreen> createState() => _GestaoFinanceiraScreenState();
}

class _GestaoFinanceiraScreenState extends State<GestaoFinanceiraScreen> {
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _prazoController = TextEditingController();
  final TextEditingController _taxaController = TextEditingController();

  String _tipoAmortizacao = 'SAC'; // SAC ou PRICE
  List<Map<String, dynamic>> _parcelas = [];

  // Função para calcular o parcelamento (Tecnologia de ponta em finanças)
  void _calcularParcelamento() {
    double valorTotal = double.tryParse(_valorController.text) ?? 0;
    int meses = int.tryParse(_prazoController.text) ?? 0;
    double taxaMensal = (double.tryParse(_taxaController.text) ?? 0) / 100;

    if (valorTotal <= 0 || meses <= 0) return;

    List<Map<String, dynamic>> tempParcelas = [];
    double saldoDevedor = valorTotal;

    if (_tipoAmortizacao == 'SAC') {
      double amortizacaoConstante = valorTotal / meses;
      for (int i = 1; i <= meses; i++) {
        double juros = saldoDevedor * taxaMensal;
        double prestacao = amortizacaoConstante + juros;
        tempParcelas.add({
          'n': i,
          'valor': prestacao,
          'juros': juros,
          'amortizacao': amortizacaoConstante,
          'saldo': (saldoDevedor - amortizacaoConstante).abs() < 0.01
              ? 0
              : saldoDevedor - amortizacaoConstante,
        });
        saldoDevedor -= amortizacaoConstante;
      }
    } else {
      // Tabela PRICE (Parcelas Fixas)
      double prestacaoFixa =
          valorTotal *
          (taxaMensal * pow(1 + taxaMensal, meses)) /
          (pow(1 + taxaMensal, meses) - 1);
      for (int i = 1; i <= meses; i++) {
        double juros = saldoDevedor * taxaMensal;
        double amortizacao = prestacaoFixa - juros;
        tempParcelas.add({
          'n': i,
          'valor': prestacaoFixa,
          'juros': juros,
          'amortizacao': amortizacao,
          'saldo': (saldoDevedor - amortizacao).abs() < 0.01
              ? 0
              : saldoDevedor - amortizacao,
        });
        saldoDevedor -= amortizacao;
      }
    }

    setState(() {
      _parcelas = tempParcelas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Simulador Financeiro"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Formulário de Entrada
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _valorController,
                      decoration: const InputDecoration(
                        labelText: "Valor do Terreno (R\$)",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _prazoController,
                            decoration: const InputDecoration(
                              labelText: "Prazo (Meses)",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _taxaController,
                            decoration: const InputDecoration(
                              labelText: "Taxa Juros (% a.m.)",
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      initialValue: _tipoAmortizacao,
                      items: const [
                        DropdownMenuItem(
                          value: 'SAC',
                          child: Text("SAC - Parcelas Decrescentes"),
                        ),
                        DropdownMenuItem(
                          value: 'PRICE',
                          child: Text("PRICE - Parcelas Fixas"),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => _tipoAmortizacao = val!),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _calcularParcelamento,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF00C853,
                        ), // Verde para sucesso financeiro [cite: 17]
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text("GERAR PLANO DE PAGAMENTO"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tabela de Resultados
            Expanded(
              child: _parcelas.isEmpty
                  ? const Center(child: Text("Preencha os dados para simular"))
                  : ListView.builder(
                      itemCount: _parcelas.length,
                      itemBuilder: (context, index) {
                        final p = _parcelas[index];
                        return ListTile(
                          leading: CircleAvatar(child: Text("${p['n']}")),
                          title: Text(
                            "Prestação: R\$ ${p['valor'].toStringAsFixed(2)}",
                          ),
                          subtitle: Text(
                            "Juros: R\$ ${p['juros'].toStringAsFixed(2)} | Amortização: R\$ ${p['amortizacao'].toStringAsFixed(2)}",
                          ),
                          trailing: Text(
                            "Saldo: R\$ ${p['saldo'].toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
