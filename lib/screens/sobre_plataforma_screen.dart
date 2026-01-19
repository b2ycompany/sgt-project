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
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            flexibleSpace: FlexibleSpaceBar(
              title: Text("O QUE É O SGT?",
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
                  ),
                ),
                child: const Icon(Icons.business_center,
                    size: 100, color: Colors.white24),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCard(
                      "Gestão Inteligente",
                      "Plataforma centralizada para controle de terrenos, documentos e fluxos financeiros.",
                      Icons.analytics),
                  _buildCard(
                      "Workflow Kanban",
                      "Visualize o status de cada lote em tempo real, desde a disponibilidade até a venda final.",
                      Icons.view_kanban),
                  _buildCard(
                      "Transparência para o Cliente",
                      "Portal exclusivo para o comprador acompanhar pagamentos e baixar contratos.",
                      Icons.person_pin),
                  const SizedBox(height: 30),
                  const Divider(),
                  const SizedBox(height: 20),
                  Text(
                    "Melhores Práticas",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "• Mantenha a documentação sempre atualizada no Cloud Storage.\n"
                    "• Utilize o Workflow para evitar gargalos na negociação.\n"
                    "• Acompanhe o comissionamento de parceiros de forma automatizada.",
                    style: TextStyle(
                        fontSize: 15, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String desc, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Icon(icon, size: 40, color: const Color(0xFF1A237E)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }
}
