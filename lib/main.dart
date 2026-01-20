import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES INTEGRAIS DE TODAS AS TELAS ---
// Garante que o fluxo: Discovery -> Cadastro -> Assinatura -> Investimento funcione.
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/onboarding_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/admin/admin_dashboard.dart';
import 'package:sgt_projeto/screens/assinatura_documento_screen.dart';

void main() async {
  // Inicialização obrigatória para plugins assíncronos
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Configuração do Firebase com correção de parâmetro camelCase para evitar erros
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
    debugPrint("--- [SGT LOG]: NÚCLEO DE SEGURANÇA FIREBASE ATIVO ---");
  } catch (e) {
    debugPrint("--- [SGT ERRO]: FALHA NA INICIALIZAÇÃO -> $e ---");
  }

  runApp(const SGTApp());
}

/// Definição da Identidade Visual Private Banking da CIG.
class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color navy = Color(0xFF050F22); // Azul Marinho Institucional
    const Color gold = Color(0xFFD4AF37); // Ouro Private
    const Color emerald = Color(0xFF2E8B57); // Verde Performance

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
          tertiary: emerald,
        ),

        // Tipografia Cinzel para Títulos e Poppins para Dados
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
            fontSize: 32,
          ),
          displayMedium: GoogleFonts.cinzel(
            color: gold,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
          bodyLarge: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        ),

        // Botões de Impacto com Sombra Dourada
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 22),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 15,
            shadowColor: gold.withOpacity(0.3),
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 2.0),
          ),
        ),

        // Inputs Minimalistas para o Discovery
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.05),
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          prefixIconColor: gold,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10),
            borderRadius: BorderRadius.zero,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: gold, width: 2.0),
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/// AuthWrapper: O Roteador Central de Status.
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

        // Se houver sessão ativa no Firebase Auth
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

              // CASO 1: Documento não existe -> Direciona ao Onboarding (Discovery)
              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const OnboardingScreen();
              }

              // Extração de metadados do perfil do investidor
              final userData = userSnap.data!.data() as Map<String, dynamic>;
              final String cargo = userData['cargo'] ?? 'cliente';
              final String status = userData['status'] ?? 'pendente';
              final String numeroFila = userData['numero_fila'] ?? "----";
              final String assinaturaStatus =
                  userData['assinatura_digital_status'] ?? 'pendente';

              // --- LÓGICA DE ROTEAMENTO POR NÍVEL DE ACESSO ---

              // A. PERFIL ADMINISTRATIVO
              if (cargo == 'admin') {
                return const AdminDashboard();
              }

              // B. PERFIL CLIENTE APROVADO
              if (status == 'aprovado') {
                // Bloqueio de Compliance: Se não assinou o termo, vai para a Assinatura
                if (assinaturaStatus == 'confirmado') {
                  return const DashboardCliente();
                } else {
                  return const AssinaturaDocumentoScreen();
                }
              }

              // C. PERFIL CLIENTE RECUSADO
              else if (status == 'recusado') {
                return const AccessDeniedScreen();
              }

              // D. PERFIL EM ANÁLISE (FILA DE ESPERA)
              else {
                return WaitingApprovalScreen(protocolo: numeroFila);
              }
            },
          );
        }
        // Se não logado: Mostra a vitrine (Landing Page)
        return const LandingPage();
      },
    );
  }
}

// --- TELAS DE ESTADO AUXILIARES ---

/// Tela de Espera Dinâmica com o Protocolo de Fila do Leonardo
class WaitingApprovalScreen extends StatelessWidget {
  final String protocolo;
  const WaitingApprovalScreen({super.key, required this.protocolo});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.5,
              colors: [Color(0xFF0A1A35), Color(0xFF050F22)]),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, color: gold, size: 100),
              const SizedBox(height: 50),
              Text(
                "ANÁLISE DE COMPLIANCE",
                style: GoogleFonts.cinzel(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 25),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                decoration: BoxDecoration(
                    border: Border.all(color: gold.withOpacity(0.3)),
                    color: gold.withOpacity(0.05)),
                child: Column(
                  children: [
                    const Text("PROTOCOLO DE FILA ÚNICA",
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text("#$protocolo",
                        style: GoogleFonts.robotoMono(
                            color: gold,
                            fontWeight: FontWeight.bold,
                            fontSize: 22)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                "Sua solicitação de acesso private está sendo processada. Aguarde a validação do seu perfil para lances em ativos USA.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: Colors.white60, height: 1.8, fontSize: 14),
              ),
              const SizedBox(height: 100),
              TextButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("ENCERRAR SESSÃO",
                    style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela para investidores que não atingiram os critérios de compliance.
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
            const Padding(
              padding: EdgeInsets.all(50.0),
              child: Text(
                "Lamentamos, mas seu perfil não atende aos critérios de elegibilidade da CIG Private para este ciclo de ativos.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, height: 1.6),
              ),
            ),
            ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text("SAIR")),
          ],
        ),
      ),
    );
  }
}
