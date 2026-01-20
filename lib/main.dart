import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importações de todas as telas
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/onboarding_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: const String.fromEnvironment('API_KEY'),
        authDomain: const String.fromEnvironment('AUTH_DOMAIN'),
        projectId: const String.fromEnvironment('PROJECT_ID'),
        storageBucket: const String.fromEnvironment(
            'STORAGE_BUCKET'), // Corrigido camelCase
        messagingSenderId: const String.fromEnvironment('MESSAGING_SENDER_ID'),
        appId: const String.fromEnvironment('APP_ID'),
      ),
    );
    debugPrint("--- CIG PRIVATE: SISTEMA ONLINE ---");
  } catch (e) {
    debugPrint("--- ERRO CRÍTICO FIREBASE: $e ---");
  }

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF050F22);
    const gold = Color(0xFFD4AF37);

    return MaterialApp(
      title: 'CIG Private Investment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: navy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: navy,
          primary: navy,
          secondary: gold,
          surface: navy,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          bodyLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 10,
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

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

              // SE NÃO EXISTE DOCUMENTO: O usuário acabou de registrar e precisa do Onboarding
              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const OnboardingScreen();
              }

              final userData = userSnap.data!.data() as Map<String, dynamic>;
              String cargo = userData['cargo'] ?? 'cliente';
              String status = userData['status'] ?? 'pendente';

              if (cargo == 'admin') return const AdminDashboard();

              if (status == 'aprovado') return const DashboardCliente();

              if (status == 'recusado') return const AccessDeniedScreen();

              // Se estiver pendente, mostra a tela de fila de espera com o número de protocolo
              return WaitingApprovalScreen(
                  protocolo: userData['numero_fila'] ?? "0000");
            },
          );
        }
        return const LandingPage();
      },
    );
  }
}

class WaitingApprovalScreen extends StatelessWidget {
  final String protocolo;
  const WaitingApprovalScreen({super.key, required this.protocolo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty_rounded,
                color: Color(0xFFD4AF37), size: 100),
            const SizedBox(height: 40),
            Text("SOLICITAÇÃO EM ANÁLISE",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("PROTOCOLO DE FILA: #$protocolo",
                style: GoogleFonts.robotoMono(
                    color: const Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text(
              "Nossa equipe de Private Banking está validando seu perfil de investidor. Você receberá um e-mail assim que seu acesso for liberado.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, height: 1.6),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
              child: const Text("SAIR DO PORTAL",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
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
            const Icon(Icons.block, color: Colors.redAccent, size: 80),
            const SizedBox(height: 20),
            const Text("ACESSO NEGADO",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const Text("Seu perfil não atende aos requisitos atuais.",
                style: TextStyle(color: Colors.white38)),
            TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("VOLTAR")),
          ],
        ),
      ),
    );
  }
}
