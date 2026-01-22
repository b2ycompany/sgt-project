import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgt_projeto/screens/login_screen.dart';

/// LANDING PAGE EXPERIMENTAL v5.0 - CIG PRIVATE INVESTMENT
/// Arquitetura de Software: Integridade Total, Alta Densidade e Responsividade.
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  // --- CONTROLADORES E ESTADOS DE NAVEGAÇÃO ---
  final PageController _carouselController = PageController();
  final ScrollController _mainScrollController = ScrollController();
  late AnimationController _waveController;
  late AnimationController _leadFormController;

  int _currentPage = 0;
  bool _isLeadSubmitting = false;

  // --- CONTROLADORES DE FORMULÁRIO (LEAD CAPTURE) ---
  final TextEditingController _leadNameController = TextEditingController();
  final TextEditingController _leadEmailController = TextEditingController();

  // --- PALETA DE CORES INSTITUCIONAL (PRIVATE BANKING) ---
  final Color gold = const Color(0xFFD4AF37);
  final Color navy = const Color(0xFF050F22);
  final Color emerald = const Color(0xFF2E8B57);
  final Color cardGlass = Colors.white.withValues(alpha: 0.04);

  @override
  void initState() {
    super.initState();

    // Motor de Ondas Matemáticas (Mantendo seu código original)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // Motor de Animação para o Formulário de Leads
    _leadFormController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Timer do Carrossel Cinematográfico
    Timer.periodic(const Duration(seconds: 8), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_carouselController.hasClients) {
        _carouselController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _leadFormController.dispose();
    _carouselController.dispose();
    _mainScrollController.dispose();
    _leadNameController.dispose();
    _leadEmailController.dispose();
    super.dispose();
  }

  // --- LÓGICA DE CAPTAÇÃO DE LEADS (NOVA) ---
  Future<void> _submitLead() async {
    if (_leadNameController.text.isEmpty ||
        !_leadEmailController.text.contains('@')) {
      _showToast("Por favor, preencha os dados corretamente.");
      return;
    }

    setState(() => _isLeadSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('leads_marketing').add({
        'nome': _leadNameController.text.trim(),
        'email': _leadEmailController.text.trim(),
        'origem': 'Landing Page - Blog USA',
        'data_captura': FieldValue.serverTimestamp(),
        'interesse': 'Ebook Land Banking 2026',
      });

      _showSuccessDialog();
    } catch (e) {
      _showToast("Erro ao processar: $e");
    } finally {
      if (mounted) setState(() => _isLeadSubmitting = false);
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent));
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: navy,
          title: Text("ACESSO LIBERADO",
              style:
                  GoogleFonts.cinzel(color: gold, fontWeight: FontWeight.bold)),
          content: const Text(
              "Seu PDF exclusivo foi enviado para o e-mail cadastrado.",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("FECHAR", style: TextStyle(color: gold)))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 900;

          return Stack(
            children: [
              // CAMADA 0: BACKGROUND ANIMADO (WAVES)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _waveController,
                  builder: (context, child) {
                    return CustomPaint(
                        painter: BackgroundWavePainter(_waveController.value));
                  },
                ),
              ),

              // CAMADA 1: CONTEÚDO SCROLLABLE (900+ LINHAS DE ELEMENTOS)
              CustomScrollView(
                controller: _mainScrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- 1. TICKER BLOOMBERG ---
                  SliverToBoxAdapter(
                    child: Container(
                      height: 45,
                      color: Colors.black.withValues(alpha: 0.9),
                      child: _buildGlobalTicker(gold),
                    ),
                  ),

                  // --- 2. HERO CAROUSEL ---
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.75
                          : MediaQuery.of(context).size.height * 0.95,
                      child: Stack(
                        children: [
                          PageView(
                            controller: _carouselController,
                            children: [
                              _buildHeroSlide(
                                  "Oportunidades Off-Market",
                                  "Acesse lotes exclusivos em áreas de alta valorização antes do mercado aberto.",
                                  "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2070",
                                  gold,
                                  isMobile),
                              _buildHeroSlide(
                                  "Segurança Jurídica USA",
                                  "Patrimônio dolarizado sob jurisdição americana sólida e transparente.",
                                  "https://images.unsplash.com/photo-1560518883-ce09059eeffa?q=80&w=1973",
                                  gold,
                                  isMobile),
                              _buildHeroSlide(
                                  "Gestão de Fortuna",
                                  "Estratégia desenhada para proteção patrimonial e lucro real em Dólar.",
                                  "https://images.unsplash.com/photo-1551288049-bebda4e38f71?q=80&w=2070",
                                  gold,
                                  isMobile),
                            ],
                          ),
                          // Gradiente de Profundidade
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [navy, Colors.transparent],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: isMobile ? 50 : 100,
                            left: isMobile ? 30 : 100,
                            child: _buildHeroCTA(context, gold, navy, isMobile),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 3. CAMPANHAS ATIVAS (REAL-TIME FIRESTORE) ---
                  SliverToBoxAdapter(
                    child:
                        _buildActiveCampaignsSection(gold, emerald, isMobile),
                  ),

                  // --- 4. INDICADORES DE PERFORMANCE (EXPANDIDOS) ---
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 80 : 150, horizontal: 20),
                      child: Column(
                        children: [
                          Text("POWERED BY CIG INTELLIGENCE",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cinzel(
                                  color: gold,
                                  fontSize: isMobile ? 12 : 16,
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 80),
                          Wrap(
                            spacing: 35,
                            runSpacing: 35,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildCounterCard("ROI MÉDIO ANUAL", 24.8,
                                  "% a.a.", emerald, isMobile),
                              _buildCounterCard("ASSETS UNDER MGMT", 45.2,
                                  "M USD", Colors.white, isMobile),
                              _buildCounterCard("INVESTIDORES PRIVATE", 1250,
                                  "+", gold, isMobile),
                              _buildCounterCard("LANCES ATIVOS", 128, " Unid.",
                                  Colors.white, isMobile),
                              _buildCounterCard("EXIT SUCCESS RATE", 99.2, "%",
                                  emerald, isMobile),
                              _buildCounterCard("USA STATES COVERED", 14,
                                  " States", gold, isMobile),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- 5. BLOG DE ATIVOS USA ---
                  SliverToBoxAdapter(
                    child: _buildBlogSection(gold, isMobile),
                  ),

                  // --- 6. CAPTAÇÃO DE LEADS (LEAD MAGNET) ---
                  SliverToBoxAdapter(
                    child: _buildLeadCaptureSection(gold, isMobile),
                  ),

                  // --- 7. METODOLOGIA E FLUXO ---
                  SliverToBoxAdapter(
                    child: _buildMethodologySection(gold, isMobile),
                  ),

                  // --- 8. DEPOIMENTOS (WALL OF TRUST) ---
                  SliverToBoxAdapter(
                    child: _buildTestimonialsSection(gold, isMobile),
                  ),

                  // --- 9. FAQ E ECOSSISTEMA ---
                  SliverToBoxAdapter(
                      child: _buildEcosystemSection(gold, isMobile)),
                  SliverToBoxAdapter(child: _buildFAQSection(gold, isMobile)),

                  // --- 10. RODAPÉ FINAL ---
                  SliverToBoxAdapter(
                    child: _buildFooterSection(gold, isMobile),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // --- SUB-MÓDULO: CAMPANHAS ATIVAS (DETALHADO) ---

  Widget _buildActiveCampaignsSection(
      Color gold, Color emerald, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 80 : 150, horizontal: isMobile ? 30 : 100),
      color: Colors.white.withValues(alpha: 0.01),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("LIVE TRACKING",
              style: GoogleFonts.cinzel(
                  color: gold,
                  fontSize: 13,
                  letterSpacing: 5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text("CAMPANHAS EM CAPTAÇÃO",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: isMobile ? 28 : 42,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
              "Acompanhe o fluxo de capital e os lances ativos do grupo private.",
              style: TextStyle(color: Colors.white24, fontSize: 14)),
          const SizedBox(height: 80),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('campanhas')
                .where('status', isEqualTo: 'ativa')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) return _emptyCampaignState();

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 3,
                  mainAxisSpacing: 40,
                  crossAxisSpacing: 40,
                  childAspectRatio: 0.72,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final camp = docs[index].data() as Map<String, dynamic>;
                  return _buildCampaignCard(camp, gold, emerald);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(
      Map<String, dynamic> data, Color gold, Color emerald) {
    double progresso = (data['arrecadado'] / data['meta']).toDouble();

    return Container(
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black54, blurRadius: 30, offset: Offset(0, 20))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(data['img_url'] ?? "",
                  height: 220, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  color: emerald,
                  child: Text("LIVE LANCE",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['titulo']?.toUpperCase() ?? "",
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
                const SizedBox(height: 25),
                _campDetail("Ativos em Carteira", "${data['ativos']} Unid."),
                _campDetail("Capital Arrecadado", "\$ ${data['arrecadado']}M"),
                _campDetail(
                    "Aporte dos Sócios", data['data_investimento'] ?? "---"),
                _campDetail("Payout Acionistas", "${data['payout']}% ROI",
                    valColor: emerald),
                const SizedBox(height: 35),
                LinearProgressIndicator(
                    value: progresso,
                    backgroundColor: Colors.white10,
                    color: gold,
                    minHeight: 2),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${(progresso * 100).toStringAsFixed(0)}% CAPTADO",
                        style: TextStyle(
                            color: gold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    Text("META: \$ ${data['meta']}M",
                        style: TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _campDetail(String label, String val, {Color? valColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          Text(val,
              style: GoogleFonts.robotoMono(
                  color: valColor ?? Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- SUB-MÓDULO: BLOG DE ATIVOS USA ---

  Widget _buildBlogSection(Color gold, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isMobile ? 80 : 150, horizontal: isMobile ? 30 : 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("CIG INTELLIGENCE",
              style: GoogleFonts.cinzel(
                  color: gold,
                  fontSize: 12,
                  letterSpacing: 5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text("INSIGHTS DO MERCADO USA",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: isMobile ? 28 : 42,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 80),
          isMobile
              ? Column(children: _getBlogPosts(gold))
              : Row(
                  children: _getBlogPosts(gold)
                      .map((e) => Expanded(child: e))
                      .toList()),
        ],
      ),
    );
  }

  List<Widget> _getBlogPosts(Color gold) {
    return [
      _blogCard(
          "Sunshine State: O Boom da Flórida",
          "Análise técnica sobre o fluxo migratório e valorização de terras em 2026.",
          "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688",
          gold),
      _blogCard(
          "Land Banking vs Real Estate",
          "Por que investir na terra bruta oferece retornos superiores a imóveis prontos.",
          "https://images.unsplash.com/photo-1464938050520-ef2270bb8ce8",
          gold),
      _blogCard(
          "A Proteção do Dólar Físico",
          "Como o patrimônio imobiliário nos EUA blinda seu capital contra inflação global.",
          "https://images.unsplash.com/photo-1454165833767-027ffea10c3b",
          gold),
    ];
  }

  Widget _blogCard(String title, String desc, String img, Color gold) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(img,
                height: 250, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 25),
          Text(title,
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(desc,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 14, height: 1.7)),
          const SizedBox(height: 25),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                Text("LER RELATÓRIO",
                    style: TextStyle(
                        color: gold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                const SizedBox(width: 10),
                Icon(Icons.arrow_right_alt, color: gold, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-MÓDULO: LEAD CAPTURE (DOWNLOAD PDF) ---

  Widget _buildLeadCaptureSection(Color gold, bool isMobile) {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: isMobile ? 20 : 100, vertical: 80),
      padding: EdgeInsets.all(isMobile ? 40 : 80),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.05),
        border: Border.all(color: gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          if (!isMobile)
            Expanded(
                child: Icon(Icons.menu_book_outlined, color: gold, size: 150)),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("MATERIAL EXCLUSIVO",
                    style: GoogleFonts.cinzel(
                        color: gold, fontSize: 12, letterSpacing: 4)),
                const SizedBox(height: 15),
                Text("BAIXE O GUIA DO LAND BANKING 2026",
                    style: GoogleFonts.cinzel(
                        color: Colors.white,
                        fontSize: isMobile ? 22 : 32,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                _leadTextField("Seu Nome Completo", _leadNameController),
                const SizedBox(height: 20),
                _leadTextField("E-mail Profissional", _leadEmailController),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 65,
                  child: ElevatedButton(
                    onPressed: _isLeadSubmitting ? null : _submitLead,
                    child: _isLeadSubmitting
                        ? CircularProgressIndicator(color: navy)
                        : const Text("RECEBER PDF NO E-MAIL"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _leadTextField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.black26,
        contentPadding: const EdgeInsets.all(22),
        enabledBorder:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
      ),
    );
  }

  // --- SUB-MÓDULO: DEPOIMENTOS (WALL OF TRUST) ---

  Widget _buildTestimonialsSection(Color gold, bool isMobile) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 150, horizontal: isMobile ? 30 : 100),
      color: Colors.white.withValues(alpha: 0.01),
      child: Column(
        children: [
          Text("VOZES DA ELITE",
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 13, letterSpacing: 6)),
          const SizedBox(height: 80),
          isMobile
              ? Column(children: _getTestimonials(gold))
              : Row(
                  children: _getTestimonials(gold)
                      .map((e) => Expanded(child: e))
                      .toList()),
        ],
      ),
    );
  }

  List<Widget> _getTestimonials(Color gold) {
    return [
      _testimonialItem(
          "Marcus V.",
          "Private Member",
          "A transparência da CIG no acompanhamento dos terrenos USA é algo que nunca vi em 20 anos de mercado financeiro.",
          gold),
      _testimonialItem(
          "Clara L.",
          "Asset Manager",
          "Dolarizar o patrimônio através de land banking foi a melhor decisão para o hedge da minha carteira familiar.",
          gold),
      _testimonialItem(
          "Roberto S.",
          "Tech Founder",
          "O portal administrativo é incrível. Ver o ROI dos meus lances em tempo real traz uma segurança imensa.",
          gold),
    ];
  }

  Widget _testimonialItem(String name, String role, String quote, Color gold) {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(45),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.02),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(
        children: [
          const Icon(Icons.format_quote, color: Colors.white10, size: 50),
          const SizedBox(height: 25),
          Text("\"$quote\"",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                  height: 1.8,
                  fontSize: 14)),
          const SizedBox(height: 40),
          Text(name.toUpperCase(),
              style: GoogleFonts.cinzel(
                  color: gold, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(role,
              style: const TextStyle(
                  color: Colors.white24, fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }

  // --- COMPONENTES ORIGINAIS PRESERVADOS E OTIMIZADOS ---

  Widget _buildGlobalTicker(Color gold) {
    final List<String> indicators = [
      "S&P 500: 5,120.4 (+1.2%)",
      "GOLD: \$2,154.20 (+0.5%)",
      "USD/BRL: R\$ 5,42 (-0.3%)",
      "FLORIDA LAND INDEX: +14.2% YTD",
      "US TREASURY 10Y: 4.22%",
      "CIG ALPHA ROI: 24.8% a.a."
    ];
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 20,
      itemBuilder: (context, index) {
        return Center(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Text(indicators[index % indicators.length],
              style: GoogleFonts.robotoMono(
                  color: gold, fontSize: 11, fontWeight: FontWeight.bold)),
        ));
      },
    );
  }

  Widget _buildHeroSlide(
      String title, String sub, String imgUrl, Color gold, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imgUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              const Color(0xFF050F22).withValues(alpha: 0.75),
              BlendMode.darken),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: isMobile ? 38 : 68,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              SizedBox(
                  width: 800,
                  child: Text(sub,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: gold.withValues(alpha: 0.9),
                          fontSize: isMobile ? 15 : 20,
                          height: 1.6,
                          fontWeight: FontWeight.w300))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCTA(
      BuildContext context, Color gold, Color navy, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
            foregroundColor: navy,
            padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 35 : 55, vertical: 30),
          ),
          child: const Text("SOLICITAR ACESSO EXCLUSIVO"),
        ),
        const SizedBox(height: 25),
        Row(children: [
          const Icon(Icons.circle, size: 8, color: Colors.green),
          const SizedBox(width: 15),
          Text("12 NOVAS OFERTAS EM CAPTAÇÃO",
              style: GoogleFonts.poppins(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2)),
        ]),
      ],
    );
  }

  Widget _buildCounterCard(
      String label, double value, String suffix, Color color, bool isMobile) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: isMobile ? MediaQuery.of(context).size.width * 0.43 : 280,
          padding: EdgeInsets.all(isMobile ? 30 : 50),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
          child: Column(children: [
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5)),
            const SizedBox(height: 25),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(seconds: 5),
              builder: (context, double val, child) {
                return Text("${val.toStringAsFixed(1)}$suffix",
                    style: GoogleFonts.cinzel(
                        color: color,
                        fontSize: isMobile ? 24 : 44,
                        fontWeight: FontWeight.bold));
              },
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildMethodologySection(Color gold, bool isMobile) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 120, horizontal: isMobile ? 30 : 100),
      color: Colors.white.withValues(alpha: 0.015),
      child: Column(
        children: [
          Text("METODOLOGIA CIG",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: isMobile ? 26 : 38,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(width: 100, height: 2, color: gold),
          const SizedBox(height: 100),
          _workflowStep("01", "DUE DILIGENCE NEURAL",
              "Algoritmos que filtram 1% dos lotes com maior potencial USA."),
          _workflowStep("02", "AQUISIÇÃO E ESTRUTURA",
              "Compra direta com proteção jurídica em nome do grupo/investidor."),
          _workflowStep("03", "VALORIZAÇÃO E EXIT",
              "Liquidação estratégica para maximização de dividendos em Dólar."),
        ],
      ),
    );
  }

  Widget _workflowStep(String num, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 35),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(num,
              style: GoogleFonts.cinzel(
                  color: gold, fontSize: 44, fontWeight: FontWeight.bold)),
          const SizedBox(width: 45),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        letterSpacing: 2)),
                const SizedBox(height: 12),
                Text(desc,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 16, height: 1.7)),
              ])),
        ],
      ),
    );
  }

  Widget _buildEcosystemSection(Color gold, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 140, horizontal: 50),
      child: Column(children: [
        const Icon(Icons.verified_user_outlined,
            color: Color(0xFFD4AF37), size: 60),
        const SizedBox(height: 30),
        Text("CONFORMIDADE E GOVERNANÇA",
            style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        const Text("Operamos sob normas SEC e jurisdição da Flórida.",
            style: TextStyle(color: Colors.white24, fontSize: 14)),
        const SizedBox(height: 80),
        _buildCounterCard("COMPLIANCE SCORE", 100, "%", emerald, isMobile),
      ]),
    );
  }

  Widget _buildFAQSection(Color gold, bool isMobile) {
    return Container(
      padding:
          EdgeInsets.symmetric(vertical: 100, horizontal: isMobile ? 30 : 120),
      color: Colors.black.withValues(alpha: 0.3),
      child: Column(
        children: [
          Text("PERGUNTAS FREQUENTES",
              style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 80),
          _faqTile("Qual o aporte mínimo?",
              "O grupo foca em investidores qualificados com aportes a partir de \$50.000 USD."),
          _faqTile("Como funcionam os lances?",
              "Os membros aprovados participam de janelas exclusivas de land banking via dashboard."),
          _faqTile("Qual o prazo de retorno?",
              "O ciclo médio de valorização e liquidação é de 18 a 36 meses."),
        ],
      ),
    );
  }

  Widget _faqTile(String q, String a) {
    return ExpansionTile(
      title: Text(q,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      children: [
        Padding(
            padding: const EdgeInsets.all(25),
            child: Text(a,
                style: const TextStyle(color: Colors.white38, height: 1.8)))
      ],
    );
  }

  Widget _buildFooterSection(Color gold, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 150),
      child: Column(
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFD4AF37), size: 70),
          const SizedBox(height: 40),
          Text("PRIVATE PRIVILEGED ACCESS",
              style: GoogleFonts.cinzel(
                  color: Colors.white24, fontSize: 16, letterSpacing: 5)),
          const SizedBox(height: 120),
          const Text("© 2026 CIG PRIVATE INVESTMENT GROUP",
              style: TextStyle(
                  color: Colors.white10, fontSize: 10, letterSpacing: 2.5)),
          const SizedBox(height: 10),
          const Text("SECURED BY ENCRYPTED DATA CHANNEL",
              style: TextStyle(color: Colors.white10, fontSize: 8)),
        ],
      ),
    );
  }

  Widget _emptyCampaignState() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
      child: Center(
          child: Text("Sincronizando novas ofertas...",
              style: TextStyle(color: Colors.white10))),
    );
  }
}

// PINTOR DE ONDAS DINÂMICAS
class BackgroundWavePainter extends CustomPainter {
  final double value;
  BackgroundWavePainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (var i = 0; i < 8; i++) {
      final path = Path();
      final yOffset = size.height * (0.15 + (i * 0.12));
      path.moveTo(0, yOffset);
      for (var x = 0.0; x <= size.width; x++) {
        final y = yOffset +
            math.sin((x / size.width * 2 * math.pi) +
                    (value * 2 * math.pi) +
                    i) *
                50;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(BackgroundWavePainter oldDelegate) => true;
}
