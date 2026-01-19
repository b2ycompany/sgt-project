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

class EliteInvestHome extends StatefulWidget {
  const EliteInvestHome({super.key});

  @override
  State<EliteInvestHome> createState() => _EliteInvestHomeState();
}

class _EliteInvestHomeState extends State<EliteInvestHome> {
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _controller,
        children: const [
          _AnimatedSlide(
            index: 0,
            title: 'O FUTURO DO\nINVESTIMENTO\nIMOBILIÁRIO',
            subtitle: 'Ativos reais • Tecnologia • Poder',
          ),
          _AnimatedSlide(
            index: 1,
            title: 'O MERCADO\nTRADICIONAL\nNÃO É PARA A ELITE',
            subtitle: 'Baixa margem • Zero controle',
          ),
          _AnimatedSlide(
            index: 2,
            title: 'COMPRAMOS\nCONSTRUÍMOS\nVALORIZAMOS',
            subtitle: 'Terrenos • Casas • Reformas',
          ),
          _AnimatedSlide(
            index: 3,
            title: 'INVESTIDORES\nCOMPRAM\nCOTAS',
            subtitle: 'Projetos selecionados',
          ),
          _AnimatedSlide(
            index: 4,
            title: '30% A 80%\nDE RETORNO',
            subtitle: 'Por projeto',
            highlight: true,
          ),
          _AnimatedSlide(
            index: 5,
            title: 'ACESSO\nLIMITADO',
            subtitle: 'As melhores oportunidades não esperam',
          ),
        ],
      ),
    );
  }
}

class _AnimatedSlide extends StatelessWidget {
  final int index;
  final String title;
  final String subtitle;
  final bool highlight;

  const _AnimatedSlide({
    required this.index,
    required this.title,
    required this.subtitle,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(viewportFraction: 1);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        double scale = 1.0;

        if (controller.hasClients && controller.position.haveDimensions) {
          final double page =
              controller.page ?? controller.initialPage.toDouble();
          final double delta = (page - index).abs();
          scale = (1 - delta * 0.35).clamp(0.0, 1.0).toDouble();
        }

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: scale,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 1.2,
                  colors: [
                    highlight
                        ? const Color.fromARGB(40, 255, 193, 7)
                        : const Color.fromARGB(25, 255, 255, 255),
                    Colors.black,
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 46,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: highlight ? Colors.amber : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 1.2,
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
