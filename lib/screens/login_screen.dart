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
  bool _isRegistering =
      false; // Define se a tela está em modo Login ou Cadastro

  // Função Principal de Autenticação
  Future<void> _handleAuth() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Preencha todos os campos."),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        // Fluxo de Cadastro
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Fluxo de Login
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      // IMPORTANTE: Após o sucesso, removemos a tela de login.
      // O AuthWrapper no main.dart detectará a mudança e abrirá o Onboarding automaticamente.
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String erro = "Falha na autenticação.";
      if (e.code == 'email-already-in-use') {
        erro = "Este e-mail já está cadastrado.";
      }
      if (e.code == 'weak-password') erro = "A senha é muito fraca.";
      if (e.code == 'user-not-found') erro = "Usuário não encontrado.";
      if (e.code == 'wrong-password') erro = "Senha incorreta.";

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(erro), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const navy = Color(0xFF050F22);

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: gold),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance, color: gold, size: 80),
              const SizedBox(height: 30),
              Text(
                _isRegistering ? "SOLICITAR ACESSO" : "LOGIN PRIVATE",
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 40),

              // Uso do componente customizado _buildField
              _buildField("E-mail Profissional", _emailController,
                  Icons.email_outlined),
              const SizedBox(height: 20),
              _buildField(
                  "Senha de Segurança", _passwordController, Icons.lock_outline,
                  obscure: true),

              const SizedBox(height: 40),

              // Botão de Ação Principal
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: navy,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: navy)
                      : Text(
                          _isRegistering
                              ? "CADASTRAR E INICIAR DISCOVERY"
                              : "ENTRAR NO PORTAL",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Alternador entre Login e Cadastro
              TextButton(
                onPressed: () =>
                    setState(() => _isRegistering = !_isRegistering),
                child: Text(
                  _isRegistering
                      ? "Já é membro? Faça Login"
                      : "Novo investidor? Cadastre-se aqui",
                  style:
                      const TextStyle(color: gold, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Componente de Campo de Texto para evitar repetição de código
  Widget _buildField(
      String label, TextEditingController controller, IconData icon,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white10),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFD4AF37)),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
      ),
    );
  }
}
