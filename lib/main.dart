import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importações de todos os módulos da plataforma SGT - CIG Private Investment
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
  // Garante a inicialização correta dos widgets antes de qualquer serviço assíncrono
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização do Firebase utilizando variáveis de ambiente injetadas no build.sh (Segurança e QA)
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
    debugPrint(
        "--- LOG SGT: INFRAESTRUTURA FIREBASE CONECTADA COM SUCESSO ---");
  } catch (e) {
    debugPrint("--- ERRO SGT: FALHA NA INICIALIZAÇÃO DO FIREBASE -> $e ---");
  }

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // DEFINIÇÃO DA PALETA DE CORES PREMIUM (Mercado de Investimento USA)
    const primaryDark = Color(0xFF0A1931); // Deep Navy (Confiança e Solidez)
    const accentGold = Color(0xFFC7A35B); // Brushed Gold (Luxo e Exclusividade)
    const profitGreen = Color(0xFF2E8B57); // Emerald Growth (Lucro e Dinheiro)

    return MaterialApp(
      title: 'SGT - CIG Private Investment',
      debugShowCheckedModeBanner: false,

      // Tema de Luxo e Alta Performance
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryDark,
          primary: primaryDark,
          secondary: accentGold,
          tertiary: profitGreen,
          surface: const Color(0xFFF4F6F9), // Fundo Off-white limpo
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: primaryDark,
          displayColor: primaryDark,
        ),
        // Personalização de botões para o padrão de investimento
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero), // Estilo Institucional
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
        ),
      ),

      // A jornada inicia sempre pela SplashScreen de alto impacto cinematográfico
      home: const SplashScreen(),
    );
  }
}

/// O AuthWrapper gerencia o roteamento baseado no estado da sessão e no cargo do usuário (RBAC)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Exibe loading enquanto verifica o status da conta
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário estiver autenticado, verificamos o cargo no Firestore
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

                // Roteamento para o Painel Administrativo ou Portal do Cliente
                if (cargo == 'admin') {
                  return const HomeScreen();
                } else {
                  return const DashboardCliente();
                }
              }

              // Padrão de segurança: se não houver perfil definido, vai para o Dashboard Cliente
              return const DashboardCliente();
            },
          );
        }

        // Se não houver sessão ativa, o investidor vê a Landing Page com indicadores de ROI
        return const LandingPage();
      },
    );
  }
}

/// Painel Principal Administrativo (Back-Office)
/// Focado em produtividade e clareza visual para gestão de ativos
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0A1931);
    const accentGold = Color(0xFFC7A35B);
    const profitGreen = Color(0xFF2E8B57);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text("CIG MANAGEMENT SYSTEM",
            style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold, color: accentGold)),
        backgroundColor: primaryDark,
        elevation: 10,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white70),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const SobrePlataformaScreen()),
            ),
            tooltip: "Guia da Plataforma",
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () => FirebaseAuth.instance.signOut(),
            tooltip: "Sair do Sistema",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "GESTÃO DE ATIVOS",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryDark,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 80, height: 4, color: accentGold),
            const SizedBox(height: 40),

            // Grid de Módulos Estratégicos
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 900 ? 5 : 2,
              mainAxisSpacing: 24,
              crossAxisSpacing: 24,
              children: [
                _buildMenuCard(
                  context,
                  "TERRENOS",
                  Icons.landscape_rounded,
                  const GestaoTerrenosScreen(),
                  primaryDark,
                ),
                _buildMenuCard(
                  context,
                  "FINANCEIRO",
                  Icons.account_balance_wallet_rounded,
                  const GestaoFinanceiraScreen(),
                  profitGreen,
                ),
                _buildMenuCard(
                  context,
                  "WORKFLOW",
                  Icons.layers_outlined,
                  const WorkflowKanbanScreen(),
                  const Color(0xFFB8860B), // Dark Goldenrod
                ),
                _buildMenuCard(
                  context,
                  "CONDOMÍNIO",
                  Icons.business_rounded,
                  const GestaoCondominioScreen(),
                  Colors.blueGrey.shade800,
                ),
                _buildMenuCard(
                  context,
                  "SOBRE SGT",
                  Icons.info_outline_rounded,
                  const SobrePlataformaScreen(),
                  const Color(0xFF4B0082), // Indigo de luxo
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construtor de cartões com design minimalista e sombra suave
  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Widget screen, Color color) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius:
              BorderRadius.circular(4), // Borda quase quadrada para seriedade
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
