import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TaskAssignmentOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TaskAssignmentOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<TaskAssignmentOverlay> createState() => _TaskAssignmentOverlayState();
}

class _TaskAssignmentOverlayState extends State<TaskAssignmentOverlay> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkController;
  bool _showCheckmark = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start pulse animation after a short delay to allow Hero to finish
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _pulseController.repeat();
      }
    });

    // Simulate backend logic
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showCheckmark = true;
        });
        _pulseController.stop();
        _checkController.forward().then((_) {
          Future.delayed(const Duration(seconds: 1), () {
            widget.onComplete();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF22C55E).withAlpha(220),
              const Color(0xFFE5F86C).withAlpha(240),
            ],
          ),
        ),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Center Animation Area
            SizedBox(
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsating Circles
                  if (!_showCheckmark)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: PulsatingCirclesPainter(_pulseController.value),
                          size: const Size(400, 400),
                        );
                      },
                    ),

                  // Center Content (Image/Icon)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: _showCheckmark
                        ? ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _checkController,
                              curve: Curves.elasticOut,
                            ),
                            child: Container(
                              width: 160,
                              height: 160,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 100,
                                ),
                              ),
                            ),
                          )
                        : Hero(
                            tag: 'issue_image',
                            child: Container(
                              width: 140,
                              height: 140,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 40),
          
          // Status Text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Text(
              _showCheckmark ? 'Task assigned' : 'Finding Volunteers to help you',
              key: ValueKey(_showCheckmark),
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: _showCheckmark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          
          const Spacer(flex: 3),
        ],
      ),
    ),
    );
  }
}

class PulsatingCirclesPainter extends CustomPainter {
  final double animationValue;

  PulsatingCirclesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final progress = (animationValue + i / 3.0) % 1.0;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final radius = progress * maxRadius;

      final paint = Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: opacity * 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PulsatingCirclesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
