import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class TaskCompletedScreen extends StatefulWidget {
  const TaskCompletedScreen({super.key});

  @override
  State<TaskCompletedScreen> createState() => _TaskCompletedScreenState();
}

class _TaskCompletedScreenState extends State<TaskCompletedScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _xpController;

  bool _isSubmitting = true;
  late String _randomQuote;

  final List<String> _quotes = [
    "Your community is going to celebrate you!",
    "You are the next superstar!",
    "Roads are scared of you!",
    "Making the world better, one step at a time.",
    "Thank you for your incredible service!",
  ];

  @override
  void initState() {
    super.initState();

    _randomQuote = _quotes[Random().nextInt(_quotes.length)];

    // Submitting pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // XP Pop-in
    _xpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Simulate network submission delay
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        _pulseController.stop();
        _xpController.forward();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _xpController.dispose();
    super.dispose();
  }

  Widget _buildSubmitting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: PulsatingCirclesLayer(_pulseController.value),
                      size: const Size(300, 300),
                    );
                  },
                ),
                // Submission Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 60,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _randomQuote,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPPage() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SlidingUpPanel(
        minHeight:
            MediaQuery.of(context).size.height *
            0.58, // Increased to fit elements bottom-up
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        header: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 30,
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF064E3B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF67B03C), // Solid green theme
          ),
          child: Column(
            children: [
              const SizedBox(height: 70),
              // Header Title
              Text(
                'MILESTONE REACHED',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 25),

              // Arched Badges
              SizedBox(
                height: 110,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(180, 90),
                      painter: ArchPainter(),
                    ),
                    _buildBadge(Icons.star, Colors.amber, -75, 10, size: 28),
                    _buildBadge(
                      Icons.emoji_events,
                      Colors.orange,
                      0,
                      -10,
                      size: 50,
                    ),
                    _buildBadge(
                      Icons.workspace_premium,
                      Colors.brown,
                      75,
                      10,
                      size: 28,
                    ),
                  ],
                ),
              ),

              Text(
                'LEVEL',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),
              Text(
                '12',
                style: GoogleFonts.poppins(
                  fontSize: 90,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 0.9,
                ),
              ),
            ],
          ),
        ),
        panel: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFEFCE8), // Cream
                Color(0xFFE5F8ED), // Mint
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 20), // Reduced handle gap
              // Enlarged Task Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Potholes',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '2km away',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'LEVEL 3',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.black87,
                                child: Icon(
                                  Icons.pets,
                                  color: Colors.white,
                                  size: 10,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Reported by Aditya B',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Image + Stamp
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: -5,
                              right: -10,
                              left: -18,
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    border: Border.all(
                                      color: const Color(0xFF22C55E),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "DONE",
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          color: const Color(0xFF064E3B),
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF22C55E),
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Scratch Cards
              SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: 0.1,
                      child: _buildCardBack(
                        const Color(0xFF68D391),
                        w: 120,
                        h: 160,
                      ),
                    ),
                    Transform.rotate(
                      angle: 0.05,
                      child: _buildCardBack(
                        const Color(0xFF7F9CF5),
                        w: 120,
                        h: 160,
                      ),
                    ),
                    Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        width: 130,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "You brought a change to your society",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF064E3B).withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 15),

              // Action Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF064E3B).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'CONTINUE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(Color bg, {double w = 130, double h = 160}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    IconData icon,
    Color color,
    double x,
    double y, {
    double size = 35,
  }) {
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Main dynamic content
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isSubmitting
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: const Color(0xFF67B03C),
                      child: SizedBox.expand(child: _buildSubmitting()),
                    )
                  : _buildXPPage(),
            ),
          ),

          // Floating Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PulsatingCirclesLayer extends CustomPainter {
  final double animationValue;
  PulsatingCirclesLayer(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + i / 3.0) % 1.0;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final radius = progress * maxRadius;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PulsatingCirclesLayer oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class ArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(-150, 40);
    path.quadraticBezierTo(size.width / 2 - 150, -40, 150, 40);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
