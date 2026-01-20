import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES DE TELAS ---
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
  // Garante a inicialização dos bindings antes de serviços assíncronos
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização do Firebase com variáveis de ambiente (Segurança em Deploy)
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
    debugPrint("--- LOG SGT: INFRAESTRUTURA CONECTADA ---");
  } catch (e) {
    debugPrint("--- ERRO SGT: FALHA NO FIREBASE -> $e ---");
  }

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DEFINIÇÃO DA PALETA DE CORES PRIVATE BANKING (Luxo e Solidez)
    const primaryDark = Color(0xFF050F22); // Deep Navy
    const accentGold = Color(0xFFD4AF37); // Brushed Gold
    const profitGreen = Color(0xFF2E8B57); // Emerald Green

    return MaterialApp(
      title: 'CIG Private Investment',
      debugShowCheckedModeBanner: false,

      // TEMA INSTITUCIONAL DE ALTA PERFORMANCE
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
        // Tipografia Cinzel para títulos épicos e Poppins para legibilidade
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
          bodyLarge: GoogleFonts.poppins(color: Colors.white),
        ),
        // Botão padrão luxo com sombra dourada
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 22),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 15,
            shadowColor: accentGold.withValues(alpha: 0.4),
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),

      // A jornada sempre inicia pela Splash Screen cinematográfica
      home: const SplashScreen(),
    );
  }
}

/// O AuthWrapper é o cérebro do roteamento baseado em funções (RBAC)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Estado de carregamento inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
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
                    body: Center(child: CircularProgressIndicator()));
              }

              // SE O DOCUMENTO NÃO EXISTE: Redireciona para o Onboarding dinâmico
              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const OnboardingScreen();
              }

              final userData = userSnap.data!.data() as Map<String, dynamic>;
              String cargo = userData['cargo'] ?? 'cliente';
              String status = userData['status'] ?? 'pendente';

              // 1. ACESSO ADMINISTRATIVO
              if (cargo == 'admin') {
                return const AdminDashboard();
              }

              // 2. ACESSO CLIENTE (Baseado no fluxo de aprovação)
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

        // SE NÃO AUTENTICADO: Exibe a Landing Page de alto impacto
        return const LandingPage();
      },
    );
  }
}

// --- TELAS AUXILIARES DE STATUS ---

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
              Text("PERFIL EM ANÁLISE",
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text(
                "Nossa equipe de compliance está revisando seus dados para garantir a exclusividade do grupo CIG Private. Você será notificado assim que o acesso for liberado.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, height: 1.6),
              ),
              const SizedBox(height: 50),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("SAIR DO PORTAL",
                    style: TextStyle(color: gold, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person, color: Colors.redAccent, size: 80),
            const SizedBox(height: 30),
            const Text("ACESSO NEGADO",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const Text(
                "Seu perfil não atende aos requisitos atuais de investimento."),
            TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("VOLTAR")),
          ],
        ),
      ),
    );
  }
}
