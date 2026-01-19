import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sgt_projeto/screens/login_screen.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFD4AF37);
    const navy = Color(0xFF050F22);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [navy, Color(0xFF142850), navy],
          ),
        ),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Hero Section com efeito Glass
            SliverToBoxAdapter(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("PROTEÇÃO E LUCRO EM DÓLAR",
                        style: GoogleFonts.poppins(
                            color: gold,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2)),
                    const SizedBox(height: 20),
                    Text("Sua Riqueza\nSem Fronteiras.",
                        style: GoogleFonts.cinzel(
                            color: Colors.white,
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            height: 1.1)),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen())),
                      child: const Text("ACESSO EXCLUSIVO"),
                    ),
                  ],
                ),
              ),
            ),

            // Seção de Indicadores com Animação Nativa
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildAnimatedMetricCard(
                        "ROI MÉDIO", 24.8, "% a.a.", Icons.trending_up),
                    _buildAnimatedMetricCard(
                        "VALOR GERADO", 12.5, "M (USD)", Icons.monetization_on),
                    _buildAnimatedMetricCard(
                        "ATIVOS GESTÃO", 450, "Lotes", Icons.location_city),
                  ],
                ),
              ),
            ),

            // Área de Membros / Login Integrada
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(60),
                color: Colors.black.withOpacity(0.3),
                child: Column(
                  children: [
                    const Icon(Icons.security, color: gold, size: 40),
                    const SizedBox(height: 20),
                    Text("PLATAFORMA CRIPTOGRAFADA",
                        style: GoogleFonts.poppins(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 40),
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen())),
                      child: const Text("LOGIN PARA MEMBROS CIG",
                          style: TextStyle(
                              color: gold, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMetricCard(
      String label, double value, String suffix, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFFD4AF37), size: 30),
              const SizedBox(height: 20),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              // CONTADOR NATIVO FLUTTER
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: value),
                duration: const Duration(seconds: 4),
                builder: (context, double val, child) {
                  return Text(
                    "${val.toStringAsFixed(1)} $suffix",
                    style: GoogleFonts.cinzel(
                        color: const Color(0xFF2E8B57),
                        fontSize: 32,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
