import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardCliente extends StatefulWidget {
  const DashboardCliente({super.key});

  @override
  State<DashboardCliente> createState() => _DashboardClienteState();
}

class _DashboardClienteState extends State<DashboardCliente> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fundo suave e moderno
      appBar: AppBar(
        title: Text(
          "Área do Cliente",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: "Sair do Sistema",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabeçalho de Boas-vindas
            _buildHeader(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Os Meus Terrenos"),
                  const SizedBox(height: 15),
                  _buildTerrenosList(),

                  const SizedBox(height: 30),
                  _buildSectionTitle("Informações do Condomínio"),
                  const SizedBox(height: 15),
                  _buildCondominioCard(),

                  const SizedBox(height: 30),
                  _buildSectionTitle("Suporte e Contato"),
                  const SizedBox(height: 15),
                  _buildSuporteCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente: Cabeçalho com Degradê
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A237E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Olá, ${user?.email?.split('@')[0] ?? 'Cliente'}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Bem-vindo ao portal da CIG Investimento.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Componente: Título de Seção
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A237E),
      ),
    );
  }

  // Componente: Lista de Terrenos Vinculados ao Cliente
  Widget _buildTerrenosList() {
    return StreamBuilder<QuerySnapshot>(
      // Aqui filtramos terrenos onde o 'clienteId' é o ID do usuário logado
      stream: FirebaseFirestore.instance
          .collection('terrenos')
          .where('clienteId', isEqualTo: user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Card(
            child: ListTile(
              title: Text("Nenhum terreno vinculado ainda."),
              subtitle: Text("Entre em contato com a administração."),
              leading: Icon(Icons.info_outline),
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ExpansionTile(
                leading: const Icon(Icons.landscape, color: Colors.green),
                title: Text(
                  data['nome'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("Status: ${data['status']}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildActionButton(
                          Icons.receipt_long,
                          "Ver Extrato Financeiro",
                          Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        _buildActionButton(
                          Icons.folder_shared,
                          "Aceder a Documentos",
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Botão de Ação para cada Terreno
  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        // Lógica de navegação para extratos e documentos
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: color),
          ],
        ),
      ),
    );
  }

  // Componente: Informações de Condomínio
  Widget _buildCondominioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.home_work, size: 40, color: Color(0xFF1A237E)),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Valor Atual", style: TextStyle(color: Colors.grey)),
              Text(
                "R\$ 350,00",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
            ),
            child: const Text("PAGAR"),
          ),
        ],
      ),
    );
  }

  // Componente: Card de Suporte
  Widget _buildSuporteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1A237E)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        children: [
          Icon(Icons.headset_mic, color: Colors.white, size: 30),
          SizedBox(width: 20),
          Text(
            "Precisa de ajuda?\nFale com o suporte técnico.",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
