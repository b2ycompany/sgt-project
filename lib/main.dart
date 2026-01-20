import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- IMPORTAÇÕES INTEGRAIS DE TODAS AS TELAS DO ECOSSISTEMA SGT ---
// O sistema agora inclui o módulo de Assinatura Digital obrigatório para Compliance.
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/onboarding_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/admin/admin_dashboard.dart';
import 'package:sgt_projeto/screens/assinatura_documento_screen.dart'; // NOVO MÓDULO
import 'package:sgt_projeto/screens/sobre_plataforma_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_terrenos_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';
import 'package:sgt_projeto/screens/back_office/workflow_kanban_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_condominio_screen.dart';

/// Ponto de entrada mestre da plataforma CIG Private Investment (v2026.1).
/// Gerencia a infraestrutura de dados e segurança de nível bancário.
void main() async {
  // Inicialização obrigatória dos bindings do Flutter Framework
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização do Firebase utilizando injeção de ambiente para segurança de ativos.
    // Parâmetro 'storageBucket' corrigido para camelCase para evitar erros de diagnóstico.
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
    debugPrint("--- [SGT INFRA]: NÚCLEO FIREBASE OPERACIONAL ---");
  } catch (e) {
    debugPrint("--- [SGT ERRO]: FALHA NA INICIALIZAÇÃO DE SERVIÇOS -> $e ---");
  }

  runApp(const SGTApp());
}

/// Definição da Identidade Visual Private Banking da CIG.
/// Arquitetura baseada em Luxo, Solidez e Confiança Institucional.
class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // PALETA DE CORES PRIVATE (Deep Navy e Brushed Gold)
    const Color primaryNavy = Color(0xFF050F22);
    const Color accentGold = Color(0xFFD4AF37);
    const Color successEmerald = Color(0xFF2E8B57);

    return MaterialApp(
      title: 'CIG Private Investment',
      debugShowCheckedModeBanner: false,

      // TEMA MATERIAL 3 INTEGRAL
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: primaryNavy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryNavy,
          primary: primaryNavy,
          secondary: accentGold,
          tertiary: successEmerald,
          surface: primaryNavy,
          onSurface: Colors.white,
        ),

        // Tipografia Cinzel para Branding e Poppins para Usabilidade
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.8,
            fontSize: 34,
          ),
          displayMedium: GoogleFonts.cinzel(
            color: accentGold,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
          ),
          bodyLarge: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),

        // Botões Institucionais com Sombra Dourada
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: primaryNavy,
            padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 24),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 20,
            shadowColor: accentGold.withValues(alpha: 0.4),
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold, letterSpacing: 2.2),
          ),
        ),

        // Decoração de Inputs de Discovery
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          prefixIconColor: accentGold,
          contentPadding: const EdgeInsets.all(22),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10),
            borderRadius: BorderRadius.zero,
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: accentGold, width: 2.0),
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),

      // A jornada inicia pela Splash Screen cinematográfica
      home: const SplashScreen(),
    );
  }
}

/// O AuthWrapper é a inteligência de roteamento RBAC (Role-Based Access Control).
/// Gerencia o fluxo: Discovery -> Compliance -> Assinatura -> Investimento.
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
                child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
          );
        }

        // Caso o usuário possua uma sessão ativa
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
                      child:
                          CircularProgressIndicator(color: Color(0xFFD4AF37))),
                );
              }

              // SE O DOCUMENTO NÃO EXISTE: Novo usuário -> Onboarding Discovery
              if (!userSnap.hasData || !userSnap.data!.exists) {
                return const OnboardingScreen();
              }

              // Extração de metadados do perfil
              final userData = userSnap.data!.data() as Map<String, dynamic>;
              final String cargo = userData['cargo'] ?? 'cliente';
              final String status = userData['status'] ?? 'pendente';
              final String numeroFila = userData['numero_fila'] ?? "----";

              // NOVO: Verificação de Assinatura Digital
              final String assinaturaStatus =
                  userData['assinatura_digital_status'] ?? 'pendente';

              // --- LÓGICA DE ROTEAMENTO INTEGRAL ---

              // 1. ACESSO ADMINISTRATIVO
              if (cargo == 'admin') {
                return const AdminDashboard();
              }

              // 2. ACESSO CLIENTE APROVADO
              if (status == 'aprovado') {
                // VERIFICAÇÃO DE COMPLIANCE: O investidor assinou o termo?
                if (assinaturaStatus == 'confirmado') {
                  return const DashboardCliente();
                } else {
                  // Redireciona para assinatura obrigatória antes do Dashboard
                  return const AssinaturaDocumentoScreen();
                }
              }

              // 3. ACESSO RECUSADO
              else if (status == 'recusado') {
                return const AccessDeniedScreen();
              }

              // 4. FILA DE ESPERA (PENDENTE)
              else {
                return WaitingApprovalScreen(protocolo: numeroFila);
              }
            },
          );
        }

        // SE NÃO HÁ LOGIN: Landing Page
        return const LandingPage();
      },
    );
  }
}

// --- TELAS DE ESTADO DE ACESSO (FUNCIONALIDADES INTEGRAIS) ---

/// Tela de Fila de Espera para o investidor em análise.
class WaitingApprovalScreen extends StatelessWidget {
  final String protocolo;
  const WaitingApprovalScreen({super.key, required this.protocolo});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [const Color(0xFF0A1A35), const Color(0xFF050F22)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user_outlined, color: gold, size: 100),
              const SizedBox(height: 50),
              Text(
                "SOLICITAÇÃO EM ANÁLISE",
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
                  border: Border.all(color: gold.withValues(alpha: 0.3)),
                  color: gold.withValues(alpha: 0.05),
                ),
                child: Column(
                  children: [
                    const Text("PROTOCOLO DE FILA",
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
                "Nossa equipe de compliance está processando seu discovery. O acesso ao portal de investimentos será liberado após a validação do seu perfil.",
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

/// Tela de Segurança para perfis não elegíveis.
class AccessDeniedScreen extends StatelessWidget {
  const AccessDeniedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(60.0),
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
              const SizedBox(height: 20),
              const Text(
                "Lamentamos, mas seu perfil não atende aos critérios de elegibilidade da CIG Private Investment para este ciclo de ativos.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, height: 1.6),
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.white10),
                child: const Text("VOLTAR AO INÍCIO",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
