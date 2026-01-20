import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES GLOBAIS DE TODAS AS TELAS DA PLATAFORMA ---
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/onboarding_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/admin/admin_dashboard.dart';
import 'package:sgt_projeto/screens/sobre_plataforma_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_terrenos_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';
import 'package:sgt_projeto/screens/back_office/workflow_kanban_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_condominio_screen.dart';

void main() async {
  // Garante a inicialização correta dos widgets antes de carregar o Firebase
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização segura do Firebase utilizando variáveis de ambiente injetadas
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: const String.fromEnvironment('API_KEY'),
        authDomain: const String.fromEnvironment('AUTH_DOMAIN'),
        projectId: const String.fromEnvironment('PROJECT_ID'),
        storageBucket: const String.fromEnvironment('STORAGE_BUCKET'),
        messagingSenderId: const String.fromEnvironment('MESSAGING_SENDER_ID'),
        appId: const String.fromEnvironment('APP_ID'),
      ),
    );
    debugPrint("--- LOG SGT: INFRAESTRUTURA FIREBASE CONECTADA ---");
  } catch (e) {
    debugPrint("--- ERRO SGT: FALHA NA CONEXÃO FIREBASE -> $e ---");
  }

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DEFINIÇÃO DA PALETA DE LUXO (Deep Navy, Brushed Gold e Emerald Growth)
    const primaryDark = Color(0xFF050F22);
    const accentGold = Color(0xFFD4AF37);
    const profitGreen = Color(0xFF2E8B57);

    return MaterialApp(
      title: 'CIG Private Investment',
      debugShowCheckedModeBanner: false,

      // TEMA DE ALTA PERFORMANCE E MERCADO FINANCEIRO
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: primaryDark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryDark,
          primary: primaryDark,
          secondary: accentGold,
          tertiary: profitGreen,
          surface: const Color(0xFFF8FAFC),
        ),
        // Tipografia Cinzel para títulos épicos e Poppins para legibilidade técnica
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
          bodyLarge: GoogleFonts.poppins(color: Colors.white),
          bodyMedium: GoogleFonts.poppins(color: Colors.white70),
        ),
        // Personalização de Botões (Padrão de Investimento USA)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 22),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero), // Estilo Institucional
            elevation: 15,
            shadowColor: accentGold.withValues(alpha: 0.3),
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
        // Estilização de Campos de Texto (Input)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          labelStyle: const TextStyle(color: Colors.white38),
          prefixIconColor: accentGold,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: accentGold),
          ),
        ),
      ),

      // Inicia na SplashScreen de impacto cinematográfico
      home: const SplashScreen(),
    );
  }
}

/// O AuthWrapper é a entidade de roteamento inteligente da plataforma.
/// Ele gerencia o acesso baseado no estado da conta e no cargo (Admin vs Cliente).
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Exibe loading enquanto o Firebase valida o token de sessão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário estiver autenticado, verificamos o perfil e status no Firestore
        if (snapshot.hasData && snapshot.data != null) {
          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(snapshot.data!.uid)
                .snapshots(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // SE O DOCUMENTO NÃO EXISTE: Redireciona para o Onboarding dinâmico
              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const OnboardingScreen();
              }

              final userData = userSnap.data!.data() as Map<String, dynamic>;
              String cargo = userData['cargo'] ?? 'cliente';
              String status = userData['status'] ?? 'pendente';

              // 1. ACESSO ADMINISTRATIVO (Back-Office CIG)
              if (cargo == 'admin') {
                return const AdminDashboard();
              }

              // 2. ACESSO CLIENTE (Baseado no fluxo de aprovação de compliance)
              if (status == 'aprovado') {
                return const DashboardCliente();
              } else if (status == 'recusado') {
                return const AccessDeniedScreen();
              } else {
                // Caso 'pendente' ou 'analise'
                return const WaitingApprovalScreen();
              }
            },
          );
        }

        // SE NÃO HÁ SESSÃO ATIVA: O investidor vê a Landing Page premium
        return const LandingPage();
      },
    );
  }
}

/// --- TELAS DE ESTADO DE ACESSO (FUNCIONALIDADES INTEGRAIS) ---

/// Tela exibida enquanto o administrador não aprova o perfil do investidor
class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    return Scaffold(
      backgroundColor: const Color(0xFF050F22),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, color: gold, size: 80),
              const SizedBox(height: 30),
              Text("CONTA EM ANÁLISE",
                  style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  )),
              const SizedBox(height: 20),
              const Text(
                "Nossa equipe de Compliance está analisando seus dados para garantir a exclusividade do grupo CIG Private. Você receberá um alerta assim que sua aprovação for concluída.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.6),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white10,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("SAIR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela de segurança para perfis que foram negados pela administração
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050F22),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, color: Colors.redAccent, size: 80),
            const SizedBox(height: 30),
            Text("ACESSO NEGADO",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                "Infelizmente seu perfil não atende aos requisitos atuais para participação no grupo de investimentos CIG.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38),
              ),
            ),
            const SizedBox(height: 50),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text("VOLTAR PARA HOME",
                  style: TextStyle(color: Color(0xFFD4AF37))),
            ),
          ],
        ),
      ),
    );
  }
}
