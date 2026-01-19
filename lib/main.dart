import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importação de todos os módulos que compõem a ecossistema SGT - CIG Investimento
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/sobre_plataforma_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_terrenos_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';
import 'package:sgt_projeto/screens/back_office/workflow_kanban_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_condominio_screen.dart';

void main() async {
  // Garante que o Flutter esteja pronto para operações assíncronas de hardware
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização do Firebase utilizando variáveis de ambiente injetadas via Vercel (Segurança e QA)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: String.fromEnvironment('API_KEY'),
        authDomain: String.fromEnvironment('AUTH_DOMAIN'),
        projectId: String.fromEnvironment('PROJECT_ID'),
        storageBucket: String.fromEnvironment('STORAGE_BUCKET'),
        messagingSenderId: String.fromEnvironment('MESSAGING_SENDER_ID'),
        appId: String.fromEnvironment('APP_ID'),
      ),
    );
    debugPrint("--- LOG SGT: INFRAESTRUTURA FIREBASE CONECTADA ---");
  } catch (e) {
    debugPrint("--- ERRO SGT: FALHA NA INICIALIZAÇÃO CRÍTICA -> $e ---");
  }

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGT - CIG Investimento',
      debugShowCheckedModeBanner: false,

      // Identidade Visual de Ponta: Azul Institucional e Verde de Performance
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Azul Institucional
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF00C853), // Verde para Gestão Financeira
        ),
        textTheme:
            GoogleFonts.poppinsTextTheme(), // Fonte moderna para investidores
      ),

      // O sistema inicia sempre pelo impacto visual da Splash Screen
      home: const SplashScreen(),
    );
  }
}

/// O AuthWrapper é o "cérebro" de roteamento do sistema.
/// Ele decide se mostra a Landing Page, o Painel Admin ou a Área do Cliente.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Enquanto verifica a sessão ativa
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Caso o usuário ESTEJA autenticado, verificamos o cargo no Firestore para roteamento RBAC
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnap.hasData && userSnap.data!.exists) {
                final Map<String, dynamic> userData =
                    userSnap.data!.data() as Map<String, dynamic>;
                String cargo = userData['cargo'] ?? 'cliente';

                // Roteamento inteligente baseado no nível de acesso
                if (cargo == 'admin') {
                  return const HomeScreen(); // Hub Administrativo
                } else {
                  return const DashboardCliente(); // Portal do Comprador
                }
              }

              // Se logado mas sem perfil, assume-se Dashboard do Cliente por segurança
              return const DashboardCliente();
            },
          );
        }

        // Caso o usuário NÃO esteja logado, ele vê a Landing Page fluida e com métricas de ROI
        return const LandingPage();
      },
    );
  }
}

/// Painel Principal Administrativo (Back-Office)
/// Organizado em uma grade moderna para facilitar a gestão de alta densidade
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fundo suave para foco na UI
      appBar: AppBar(
        title: const Text("Gestão Interna CIG"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          // Botão de suporte e documentação rápida
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SobrePlataformaScreen()),
            ),
            tooltip: "Guia de Uso",
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: "Sair do Sistema",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Painel de Controle",
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 20),

            // Grid de Módulos Operacionais
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: [
                _buildMenuCard(
                  context,
                  "Terrenos",
                  Icons.landscape,
                  const GestaoTerrenosScreen(),
                  const Color(0xFF1A237E),
                ),
                _buildMenuCard(
                  context,
                  "Financeiro",
                  Icons.calculate,
                  const GestaoFinanceiraScreen(),
                  const Color(0xFF00C853), // Cor de performance
                ),
                _buildMenuCard(
                  context,
                  "Workflow",
                  Icons.view_kanban,
                  const WorkflowKanbanScreen(),
                  Colors.orange,
                ),
                _buildMenuCard(
                  context,
                  "Condomínio",
                  Icons.home_work,
                  const GestaoCondominioScreen(),
                  Colors.blueGrey,
                ),
                _buildMenuCard(
                  context,
                  "Guia SGT",
                  Icons.info,
                  const SobrePlataformaScreen(),
                  Colors.purple,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construtor de Cartões de Menu com feedback visual animado
  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Widget screen, Color color) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
