import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importação de todas as telas do sistema
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/back_office/gestao_terrenos_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';

void main() async {
  // Garante a inicialização dos componentes do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Firebase (Essencial para Banco de Dados e Autenticação)
  await Firebase.initializeApp();

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGT - CIG Investimento',
      debugShowCheckedModeBanner: false,

      // Definição da identidade visual tecnológica (Tecnologia de Ponta)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Azul Institucional
          primary: const Color(0xFF1A237E),
          secondary: const Color(0xFF00C853), // Verde para Financeiro
        ),
        textTheme:
            GoogleFonts.poppinsTextTheme(), // Fonte moderna para investidores
      ),

      // O sistema inicia sempre pela Splash Screen de alto impacto
      home: const SplashScreen(),
    );
  }
}

// O AuthWrapper é o "cérebro" da navegação.
// Ele decide se o usuário vai para o Login ou para o Dashboard correto.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Verifica se o usuário está autenticado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // 2. Se logado, verifica o cargo (role) no Firestore para redirecionar
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

              // Se o documento do usuário existir, verifica se é admin ou cliente
              if (userSnap.hasData && userSnap.data!.exists) {
                final Map<String, dynamic> userData =
                    userSnap.data!.data() as Map<String, dynamic>;
                String cargo = userData['cargo'] ?? 'cliente';

                if (cargo == 'admin') {
                  return const HomeScreen(); // Menu do Administrador
                } else {
                  return const DashboardCliente(); // Portal do Comprador
                }
              }

              // Caso o usuário não tenha perfil no Firestore, assume-se Cliente por segurança
              return const DashboardCliente();
            },
          );
        }

        // 3. Se não houver sessão ativa, mostra a tela de Login
        return const LoginScreen();
      },
    );
  }
}

// Tela Principal Administrativa (Back-Office)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SGT - Painel Administrativo"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Color(0xFF1A237E),
            ),
            const SizedBox(height: 20),
            const Text(
              "Bem-vindo, Administrador",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Botão para Gestão de Terrenos
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GestaoTerrenosScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.landscape),
              label: const Text("GERIR TERRENOS E DOCUMENTOS"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Botão para Gestão Financeira
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GestaoFinanceiraScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.calculate),
              label: const Text("SIMULADOR FINANCEIRO (SAC/PRICE)"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
