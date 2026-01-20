import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES DE TELAS (Discovery, Admin e Private Client) ---
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/onboarding_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/admin/admin_dashboard.dart';

// Nota: O import do login_screen foi removido aqui pois ele é chamado
// pela LandingPage, evitando o aviso de "unused import" no main.dart.

void main() async {
  // Inicialização essencial para execução de plugins assíncronos
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // CORREÇÃO: storageBucket (camelCase) para evitar o erro de parâmetro indefinido
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
    debugPrint("--- SGT LOG: INFRAESTRUTURA FIREBASE ONLINE (2026) ---");
  } catch (e) {
    debugPrint("--- SGT ERRO: FALHA NA CONEXÃO -> $e ---");
  }

  runApp(const SGTApp());
}

// --- CLASSE MESTRE DO APLICATIVO ---
class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta Institucional: Deep Navy e Brushed Gold
    const navy = Color(0xFF050F22);
    const gold = Color(0xFFD4AF37);

    return MaterialApp(
      title: 'CIG Private Investment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
            seedColor: navy, primary: navy, secondary: gold),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Design de Botões High-End
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 12,
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
      // Início obrigatório via Splash Screen Cinematográfica
      home: const SplashScreen(),
    );
  }
}

// --- CÉREBRO DE ROTEAMENTO (AUTH & COMPLIANCE) ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Validação inicial da sessão
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // Se houver sessão, verificamos o perfil detalhado no Firestore
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

              // SE O DOCUMENTO NÃO EXISTE: Novo lead detectado -> Direciona ao Onboarding (Discovery)
              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const OnboardingScreen();
              }

              final userData = userSnap.data!.data() as Map<String, dynamic>;
              String cargo = userData['cargo'] ?? 'cliente';
              String status = userData['status'] ?? 'pendente';

              // LÓGICA DE ACESSO POR FUNÇÃO
              if (cargo == 'admin') {
                return const AdminDashboard();
              }

              if (status == 'aprovado') {
                return const DashboardCliente();
              } else if (status == 'recusado') {
                return const AccessDeniedScreen();
              } else {
                // Caso o investidor ainda esteja em análise de KYC
                return const WaitingApprovalScreen();
              }
            },
          );
        }

        // SE NÃO HÁ LOGIN: Exibe a Landing Page de Luxo
        return const LandingPage();
      },
    );
  }
}

// --- TELA DE ESPERA: ANALISE DE COMPLIANCE ---
class WaitingApprovalScreen extends StatelessWidget {
  const WaitingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, color: gold, size: 80),
              const SizedBox(height: 30),
              Text("VERIFICAÇÃO DE PERFIL",
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text(
                  "Sua solicitação de acesso private foi recebida. Nossa equipe de compliance está revisando seu perfil para liberação do portal de ativos.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, height: 1.5)),
              const SizedBox(height: 50),
              TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text("CANCELAR E SAIR",
                      style: TextStyle(color: gold))),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TELA DE ACESSO NEGADO ---
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block_flipped, color: Colors.redAccent, size: 80),
            const SizedBox(height: 30),
            Text("ACESSO INDISPONÍVEL",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.all(45.0),
              child: Text(
                "No momento, seu perfil não atende aos requisitos de entrada para as cotas de investimento CIG Private.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38),
              ),
            ),
            ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("VOLTAR AO INÍCIO")),
          ],
        ),
      ),
    );
  }
}
