import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES INTEGRAIS ---
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/onboarding_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/admin/admin_dashboard.dart';
import 'package:sgt_projeto/screens/assinatura_documento_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
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
    debugPrint("--- [SGT INFRA]: SISTEMA OPERACIONAL ---");
  } catch (e) {
    debugPrint("--- [ERRO FIREBASE]: $e ---");
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
            seedColor: navy, primary: navy, secondary: gold),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5),
          bodyLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 15,
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
              body: Center(
                  child: CircularProgressIndicator(color: Color(0xFFD4AF37))));
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
                    body: Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFD4AF37))));
              }

              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const OnboardingScreen();
              }

              final userData = userSnap.data!.data() as Map<String, dynamic>;
              final String cargo = userData['cargo'] ?? 'cliente';
              final String status = userData['status'] ?? 'pendente';
              final String numeroFila = userData['numero_fila'] ?? "----";
              final String assinaturaStatus =
                  userData['assinatura_digital_status'] ?? 'pendente';

              if (cargo == 'admin') return const AdminDashboard();

              if (status == 'aprovado') {
                return assinaturaStatus == 'confirmado'
                    ? const DashboardCliente()
                    : const AssinaturaDocumentoScreen();
              }

              if (status == 'recusado') return const AccessDeniedScreen();

              return WaitingApprovalScreen(protocolo: numeroFila);
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
    const gold = Color(0xFFD4AF37);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, color: gold, size: 100),
              const SizedBox(height: 50),
              Text("SOLICITAÇÃO EM ANÁLISE",
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
              const SizedBox(height: 25),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                    border: Border.all(color: gold.withOpacity(0.3)),
                    color: gold.withOpacity(0.05)),
                child: Column(children: [
                  const Text("PROTOCOLO DE FILA",
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                  Text("#$protocolo",
                      style: GoogleFonts.robotoMono(
                          color: gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 22)),
                ]),
              ),
              const SizedBox(height: 100),
              TextButton(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  child: const Text("SAIR",
                      style:
                          TextStyle(color: gold, fontWeight: FontWeight.bold))),
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
            const Icon(Icons.lock_person_outlined,
                color: Colors.redAccent, size: 85),
            const SizedBox(height: 40),
            Text("ACESSO RESTRITO",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 80),
            ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("SAIR")),
          ],
        ),
      ),
    );
  }
}
