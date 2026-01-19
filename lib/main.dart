import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importação das telas completas
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
  WidgetsFlutterBinding.ensureInitialized();
  try {
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
  } catch (e) {
    debugPrint("Erro Firebase: $e");
  }
  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Paleta de Cores Private Banking
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
        textTheme: GoogleFonts.cinzelTextTheme().copyWith(
          displayLarge: GoogleFonts.cinzel(
              color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: GoogleFonts.poppins(color: primaryDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGold,
            foregroundColor: primaryDark,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 15,
            shadowColor: accentGold.withOpacity(0.4),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("CIG ADMIN PANEL"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          _buildMenuCard(context, "TERRENOS", Icons.landscape,
              const GestaoTerrenosScreen(), const Color(0xFF050F22)),
          _buildMenuCard(context, "FINANCEIRO", Icons.payments,
              const GestaoFinanceiraScreen(), const Color(0xFF2E8B57)),
          _buildMenuCard(context, "WORKFLOW", Icons.account_tree,
              const WorkflowKanbanScreen(), const Color(0xFFD4AF37)),
          _buildMenuCard(context, "CONDOMÍNIO", Icons.domain,
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
                color: color.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
