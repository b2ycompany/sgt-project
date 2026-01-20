import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) =>
                CustomPaint(painter: BackgroundPainter(_controller.value)),
          ),
          SingleChildScrollView(
            child: Column(
              children: const [
                HeroSection(),
                MarketIndicators(),
                WhyInvestSection(),
                GrowthSimulation(),
                CallToAction(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------- HERO ---------------------- */

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 32),
      child: Column(
        children: [
          TweenAnimationBuilder(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.8, end: 1.0),
            builder: (_, value, child) => Transform.scale(
              scale: value,
              child: child,
            ),
            child: const Text(
              "Invista em Ativos Imobiliários\ncom Inteligência e Exclusividade",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 46,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Acesso privado a oportunidades de alto retorno.\nTecnologia, dados e curadoria profissional.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------------- KPIs ---------------------- */

class MarketIndicators extends StatelessWidget {
  const MarketIndicators({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Wrap(
        spacing: 24,
        runSpacing: 24,
        alignment: WrapAlignment.center,
        children: const [
          KPI(title: "ROI Médio", value: "28%", subtitle: "Ao ano"),
          KPI(title: "Ticket Médio", value: "R\$ 50K"),
          KPI(title: "Prazo Retorno", value: "18 Meses"),
          KPI(title: "Ativos", value: "120+", subtitle: "Operações"),
        ],
      ),
    );
  }
}

class KPI extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const KPI(
      {super.key, required this.title, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 220,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.06),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            if (subtitle != null)
              Text(subtitle!, style: const TextStyle(color: Colors.white60)),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

/* ---------------------- WHY INVEST ---------------------- */

class WhyInvestSection extends StatelessWidget {
  const WhyInvestSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 32),
      child: Column(
        children: const [
          Text(
            "Por que investidores experientes escolhem nossa plataforma?",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 40),
          Feature(text: "Aquisição abaixo do valor de mercado"),
          Feature(text: "Gestão completa do ativo"),
          Feature(text: "Estrutura jurídica segura"),
          Feature(text: "Liquidez planejada"),
        ],
      ),
    );
  }
}

class Feature extends StatelessWidget {
  final String text;
  const Feature({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent),
          const SizedBox(width: 12),
          Text(text,
              style: const TextStyle(fontSize: 18, color: Colors.white70)),
        ],
      ),
    );
  }
}

/* ---------------------- SIMULATION ---------------------- */

class GrowthSimulation extends StatelessWidget {
  const GrowthSimulation({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 120),
      child: Column(
        children: [
          const Text(
            "Simulação de Crescimento do Capital",
            style: TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 40),
          TweenAnimationBuilder(
            duration: const Duration(seconds: 3),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (_, value, __) => Container(
              width: 600 * value,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Colors.greenAccent, Colors.blueAccent],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Exemplo: R\$100K → R\$128K em 12 meses",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

/* ---------------------- CTA ---------------------- */

class CallToAction extends StatelessWidget {
  const CallToAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 22),
          backgroundColor: Colors.greenAccent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: () {},
        child: const Text(
          "Solicitar Acesso Exclusivo",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
    );
  }
}

/* ---------------------- BACKGROUND ---------------------- */

class BackgroundPainter extends CustomPainter {
  final double progress;
  BackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.blueAccent.withOpacity(0.2),
          Colors.purpleAccent.withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.width));

    final path = Path();
    for (double x = 0; x < size.width; x++) {
      path.lineTo(
          x,
          size.height / 2 +
              sin((x / size.width * 2 * pi) + progress * 2 * pi) * 40);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
