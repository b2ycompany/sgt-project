import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SobrePlataformaScreen extends StatelessWidget {
  const SobrePlataformaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // AppBar com efeito de imagem e título dinâmico
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "SGT - Inteligência Imobiliária",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.hub, size: 80, color: Colors.white24),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Como funciona a Plataforma?"),
                  const SizedBox(height: 15),
                  _buildStepCard(
                      "1",
                      "Gestão de Lotes",
                      "Controle total desde o cadastro do terreno até a entrega das chaves, com histórico em tempo real.",
                      Icons.map),
                  _buildStepCard(
                      "2",
                      "Fluxo de Venda (Kanban)",
                      "Acompanhe o funil de vendas arrastando lotes entre as fases de negociação e venda final.",
                      Icons.view_kanban),
                  _buildStepCard(
                      "3",
                      "Inteligência Financeira",
                      "Cálculos automáticos de tabelas SAC/PRICE e gestão de comissionamento de parceiros.",
                      Icons.account_balance_wallet),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Melhores Práticas de Investimento"),
                  const SizedBox(height: 15),
                  _buildBestPractices(),
                  const SizedBox(height: 30),
                  _buildEffectBanner(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A237E),
      ),
    );
  }

  Widget _buildStepCard(
      String number, String title, String desc, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF1A237E),
            child: Text(number, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                Text(desc,
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFF00C853), size: 30),
        ],
      ),
    );
  }

  Widget _buildBestPractices() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          _PracticeItem(Icons.verified,
              "Transparência: Todos os contratos são criptografados e auditáveis."),
          _PracticeItem(Icons.trending_up,
              "Valorização: O sistema analisa a curva de valorização regional."),
          _PracticeItem(Icons.security,
              "Conformidade: Documentação 100% alinhada com as normas imobiliárias."),
        ],
      ),
    );
  }

  Widget _buildEffectBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
            colors: [Color(0xFF00C853), Color(0xFF2E7D32)]),
      ),
      child: const Column(
        children: [
          Icon(Icons.rocket_launch, color: Colors.white, size: 50),
          SizedBox(height: 15),
          Text(
            "Pronto para Escalar?",
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "O SGT automatiza processos para você focar no fechamento.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _PracticeItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PracticeItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 15),
          Expanded(
              child: Text(text,
                  style: const TextStyle(color: Colors.white, fontSize: 13))),
        ],
      ),
    );
  }
}
