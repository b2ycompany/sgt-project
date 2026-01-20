import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isRegistering = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // FECHA A TELA PARA QUE O AUTHWRAPPER ABRA O ONBOARDING OU DASHBOARD
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF050F22);
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
          backgroundColor: navy,
          iconTheme: const IconThemeData(color: gold),
          elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                const Icon(Icons.account_balance, size: 70, color: gold),
                const SizedBox(height: 40),
                TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("E-mail")),
                const SizedBox(height: 20),
                TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputStyle("Senha")),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: navy)
                        : Text(_isRegistering ? "CRIAR CONTA" : "ENTRAR"),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _isRegistering = !_isRegistering),
                  child: Text(
                      _isRegistering
                          ? "Já tem conta? Login"
                          : "Novo investidor? Cadastre-se",
                      style: const TextStyle(color: gold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10)),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37))),
    );
  }
}
