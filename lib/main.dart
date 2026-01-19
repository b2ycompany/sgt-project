import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importações dos módulos SGT
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/landing_page.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/sobre_plataforma_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_terrenos_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';
import 'package:sgt_projeto/screens/back_office/workflow_kanban_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_condominio_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicialização segura via Variáveis de Ambiente na Vercel
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
  } catch (e) {
    debugPrint("Erro Firebase: $e");
  }

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta de Cores Private Banking (Luxo Absoluto)
    const primaryDark = Color(0xFF050F22);
    const accentGold = Color(0xFFD4AF37);

    return MaterialApp(
      title: 'CIG Private Investment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryDark,
          primary: primaryDark,
          secondary: accentGold,
          surface: const Color(0xFFF8FAFC),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
              color: Colors.white, fontWeight: FontWeight.bold),
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
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('usuarios')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }

              if (userSnap.hasData && userSnap.data!.exists) {
                String cargo = userSnap.data!['cargo'] ?? 'cliente';
                return cargo == 'admin'
                    ? const HomeScreen()
                    : const DashboardCliente();
              }
              return const DashboardCliente();
            },
          );
        }
        return const LandingPage();
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF050F22);
    const accentGold = Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: Text("CIG PRIVATE PANEL",
            style: GoogleFonts.cinzel(
                fontWeight: FontWeight.bold, fontSize: 16, color: accentGold)),
        backgroundColor: primaryDark,
        elevation: 0,
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(32),
        crossAxisCount: MediaQuery.of(context).size.width > 900 ? 5 : 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        children: [
          _buildMenuCard(context, "TERRENOS", Icons.landscape,
              const GestaoTerrenosScreen(), primaryDark),
          _buildMenuCard(context, "FINANCEIRO", Icons.account_balance_wallet,
              const GestaoFinanceiraScreen(), const Color(0xFF2E8B57)),
          _buildMenuCard(context, "WORKFLOW", Icons.account_tree,
              const WorkflowKanbanScreen(), accentGold),
          _buildMenuCard(context, "CONDOMÍNIO", Icons.business,
              const GestaoCondominioScreen(), Colors.blueGrey),
          _buildMenuCard(context, "SOBRE", Icons.info_outline,
              const SobrePlataformaScreen(), Colors.purple),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon,
      Widget screen, Color color) {
    return InkWell(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.white),
            const SizedBox(height: 15),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1)),
          ],
        ),
      ),
    );
  }
}
