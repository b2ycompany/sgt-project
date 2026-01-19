import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Importação de todos os módulos previstos no escopo do projeto SGT
import 'package:sgt_projeto/screens/splash_screen.dart';
import 'package:sgt_projeto/screens/login_screen.dart';
import 'package:sgt_projeto/screens/dashboard_cliente.dart';
import 'package:sgt_projeto/screens/back_office/gestao_terrenos_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_financeira_screen.dart';
import 'package:sgt_projeto/screens/back_office/workflow_kanban_screen.dart';
import 'package:sgt_projeto/screens/back_office/gestao_condominio_screen.dart';

void main() async {
  // Garante a inicialização dos componentes nativos do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialização do Firebase utilizando Variáveis de Ambiente para segurança (QA e Arquitetura)
  // As chaves são injetadas pelo script de build na Vercel
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

  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SGT - CIG Investimento',
      debugShowCheckedModeBanner: false,

      // Definição da Identidade Visual (Tecnologia de Ponta)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A237E), // Azul Institucional CIG
          primary: const Color(0xFF1A237E),
          secondary: const Color(
            0xFF00C853,
          ), // Verde para Gestão Financeira/Vendas
        ),
        textTheme:
            GoogleFonts.poppinsTextTheme(), // Fonte moderna para investidores
      ),

      // Início obrigatório pela Splash Screen de alto impacto
      home: const SplashScreen(),
    );
  }
}

/// O AuthWrapper gerencia o estado da sessão e o nível de acesso (RBAC)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Verifica se a conexão com o Firebase Auth está ativa
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o usuário estiver autenticado, verificamos o perfil no Firestore
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

              // Verifica o cargo para decidir entre Back-Office ou Dashboard do Cliente
              if (userSnap.hasData && userSnap.data!.exists) {
                final Map<String, dynamic> userData =
                    userSnap.data!.data() as Map<String, dynamic>;
                String cargo = userData['cargo'] ?? 'cliente';

                if (cargo == 'admin') {
                  return const HomeScreen(); // Acesso Administrativo
                } else {
                  return const DashboardCliente(); // Acesso Pós-Venda
                }
              }

              // Caso o perfil não exista, redireciona para o Dashboard do Cliente por padrão
              return const DashboardCliente();
            },
          );
        }

        // Caso não haja usuário logado, exibe a tela de Login
        return const LoginScreen();
      },
    );
  }
}

/// Painel Principal Administrativo (Back-Office)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel Administrativo SGT"),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sair do Sistema",
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          // Módulo: Gestão de Terrenos
          _buildMenuCard(
            context,
            "Terrenos",
            Icons.landscape,
            const GestaoTerrenosScreen(),
            const Color(0xFF1A237E),
          ),
          // Módulo: Gestão Financeira e Vendas
          _buildMenuCard(
            context,
            "Financeiro",
            Icons.calculate,
            const GestaoFinanceiraScreen(),
            const Color(0xFF00C853),
          ),
          // Módulo: Gestão de Workflow (Kanban)
          _buildMenuCard(
            context,
            "Workflow",
            Icons.view_kanban,
            const WorkflowKanbanScreen(),
            Colors.orange,
          ),
          // Módulo: Gestão de Condomínio
          _buildMenuCard(
            context,
            "Condomínio",
            Icons.home_work,
            const GestaoCondominioScreen(),
            Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  /// Construtor visual para os cards do menu administrativo
  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
    Color color,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      ),
      child: Container(
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
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
