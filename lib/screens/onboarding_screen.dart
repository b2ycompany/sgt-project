import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nomeController = TextEditingController();
  String _perfil = "Conservador";

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .set({
        'nome': _nomeController.text.trim(),
        'perfil_investidor': _perfil,
        'status': 'pendente', // Status inicial solicitado
        'cargo': 'cliente',
        'email': user.email,
        'data_solicitacao': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050F22),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("PERFIL DO INVESTIDOR",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            TextField(
              controller: _nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                  labelText: "Nome Completo",
                  labelStyle: TextStyle(color: Colors.white38)),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _perfil,
              dropdownColor: const Color(0xFF050F22),
              items:
                  ["Conservador", "Moderado", "Agressivo"].map((String value) {
                return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Colors.white)));
              }).toList(),
              onChanged: (val) => setState(() => _perfil = val!),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
                onPressed: _saveProfile,
                child: const Text("SUBMETER PARA ANÁLISE")),
          ],
        ),
      ),
    );
  }
}
