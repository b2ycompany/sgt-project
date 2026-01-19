import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SGTApp());
}

class SGTApp extends StatelessWidget {
  const SGTApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

/* ================= APRESENTAÇÃO ================= */

class EliteInvestHome extends StatelessWidget {
  const EliteInvestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: PageView(
        physics: const BouncingScrollPhysics(),
        children: const [
          _HeroSlide(),
          _ProblemSlide(),
          _SolutionSlide(),
          _HowItWorksSlide(),
          _ReturnsSlide(),
          _ExclusivitySlide(),
          _FinalSlide(),
        ],
      ),
    );
  }
}

/* ================= SLIDES ================= */

class _HeroSlide extends StatelessWidget {
  const _HeroSlide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'O FUTURO DO\nINVESTIMENTO\nIMOBILIÁRIO',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Ativos reais • Cotas digitais • Alta performance',
              style: TextStyle(
                fontSize: 18,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProblemSlide extends StatelessWidget {
  const _ProblemSlide();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(70),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'O mercado tradicional\nlimita o investidor.',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          Text(
            '• Fundos engessados\n'
            '• Pouca transparência\n'
            '• Baixa margem\n'
            '• Zero controle',
            style: TextStyle(
              fontSize: 22,
              height: 1.8,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _SolutionSlide extends StatelessWidget {
  const _SolutionSlide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'A elite investe direto\nno ativo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
              'Terrenos • Casas • Reformas • Construções',
              style: TextStyle(
                fontSize: 22,
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowItWorksSlide extends StatelessWidget {
  const _HowItWorksSlide();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Como o capital cresce',
              style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Text(
              '1. Compra estratégica\n'
              '2. Valorização ativa\n'
              '3. Cotas para investidores\n'
              '4. Venda com lucro elevado',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReturnsSlide extends StatelessWidget {
  const _ReturnsSlide();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '30% a 80%\npor projeto',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 46,
          fontWeight: FontWeight.bold,
          color: Colors.amber,
        ),
      ),
    );
  }
}

class _ExclusivitySlide extends StatelessWidget {
  const _ExclusivitySlide();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Acesso limitado\nCapital inteligente',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 44),
      ),
    );
  }
}

class _FinalSlide extends StatelessWidget {
  const _FinalSlide();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'As melhores oportunidades\nnão esperam.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 38, color: Colors.amber),
      ),
    );
  }
}
