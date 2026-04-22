import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../services/heatmap_api_service.dart';
import 'camera_screen.dart';
import 'survey_screen.dart';

class ProblemSolvingScreen extends StatefulWidget {
  final Map<String, dynamic>? issue;
  final VoidCallback? onClose;

  const ProblemSolvingScreen({super.key, this.issue, this.onClose});

  @override
  State<ProblemSolvingScreen> createState() => _ProblemSolvingScreenState();
}

class _ProblemSolvingScreenState extends State<ProblemSolvingScreen> {
  int _secondsElapsed = 0;
  Timer? _timer;
  int _selectedStatusIndex =
      -1; // -1: None, 0: Green, 1: Yellow, 2: Orange, 3: Red
  final ValueNotifier<double> _panelPosition = ValueNotifier(
    1.0,
  ); // Starts OPEN

  final List<Map<String, dynamic>> _steps = [
    {
      'text': 'Visit Community center to collect materials and tools',
      'completed': false,
    },
    {'text': 'Reach the Pothole spot', 'completed': false},
    {
      'text': 'Fill the pothole with tar/gravel and fix the issue',
      'completed': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _panelPosition.dispose();
    super.dispose();
  }

  String _formatTime() {
    int days = _secondsElapsed ~/ (24 * 3600);
    int hours = (_secondsElapsed % (24 * 3600)) ~/ 3600;
    int minutes = (_secondsElapsed % 3600) ~/ 60;
    // int seconds = _secondsElapsed % 60; // Usually hidden in UI like this
    return '${days}D:${hours}H:${minutes}M';
  }

  Color _getButtonColor() {
    switch (_selectedStatusIndex) {
      case 0:
        return const Color(0xFF22C55E); // Green
      case 1:
        return Colors.yellow[600]!; // Yellow
      case 2:
        return Colors.orange[600]!; // Orange
      case 3:
        return Colors.red[600]!; // Red
      default:
        return Colors.grey;
    }
  }

  String _getButtonText() {
    switch (_selectedStatusIndex) {
      case 0:
        return 'Task Completed';
      case 1:
        return 'Partially Completed';
      case 2:
        return 'Inspected';
      case 3:
        return 'Can\'t be done';
      default:
        return 'Select Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Image (The Issue Image)
        Positioned.fill(
          child: Hero(
            tag: 'issue_image',
            child: Image.network(
              'https://images.unsplash.com/photo-1599420186946-7b6fb4e297f0?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[800]),
            ),
          ),
        ),

        // Stronger white overlay for maximum readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.85),
                  Colors.white.withValues(alpha: 0.70),
                  Colors.white.withValues(alpha: 0.50),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
        ),

        // Vertical ribbed glass texture overlay (matching mockup)
        Positioned.fill(
          child: CustomPaint(painter: _VerticalRibbedGlassPainter()),
        ),

        // Content Layer - Original flat checklist style
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Back Button
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 16),

                // Checklist
                ..._steps.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${idx + 1}.',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A2B), // Dark green/black
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            step['text'],
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: const Color(
                                0xFF1E3A2B,
                              ), // Dark green/black
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _steps[idx]['completed'] =
                                  !_steps[idx]['completed'];
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFDFF9D8,
                              ), // Light green checkbox bg
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(
                                  0xFF1E3A2B,
                                ).withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: step['completed']
                                ? const Icon(
                                    Icons.check,
                                    color: Color(0xFF1E3A2B),
                                    size: 20,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // 4. Sliding Panel
        SlidingUpPanel(
          minHeight: 140,
          maxHeight: 450, // Reverted to original height
          color: Colors.transparent,
          boxShadow: const [],
          defaultPanelState: PanelState.OPEN,
          onPanelSlide: (pos) => _panelPosition.value = pos,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          panelBuilder: (sc) => _buildPanel(sc),
        ),

        // 5. Floating HUD (Synced with Panel Position)
        ValueListenableBuilder<double>(
          valueListenable: _panelPosition,
          builder: (context, pos, child) {
            // Calculate height in pixels: minHeight + (maxHeight - minHeight) * pos
            final maxHeight = 450.0;
            final currentHeight = 140 + (maxHeight - 140) * pos;
            return Positioned(
              bottom: currentHeight + 12, // Gap of 12px
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        _formatTime(),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          _buildStatusCircle(0, const Color(0xFF22C55E)),
                          _buildStatusCircle(1, Colors.yellow[600]!),
                          _buildStatusCircle(2, Colors.orange[600]!),
                          _buildStatusCircle(3, Colors.red[600]!),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPanel(ScrollController sc) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5F8ED), Color(0xFF86EFAC)],
        ),
      ),
      child: Stack(
        children: [
          // Scrollable content area
          ListView(
            controller: sc,
            physics:
                const NeverScrollableScrollPhysics(), // Disabling internal scrolling as requested
            padding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              110,
            ), // Precise bottom padding for button clearance
            children: [
              // Grabber
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(38),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // Title/Issue Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.issue?['title'] ?? 'Potholes',
                          style: GoogleFonts.poppins(
                            fontSize: 34, // Reduced from 44
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1E3A2B),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '2km away',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'LEVEL 3',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Reported by Aditya B',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 80, // Reduced from 100
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=300&q=80',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 40, // Reduced from 50
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: const Icon(
                              Icons.image,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Volunteers',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF22C55E),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildVolunteerItem('You', null, isMe: true),
                          const Divider(),
                          _buildVolunteerItem('Chauhan', Icons.phone),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F8ED),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Help',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const Icon(Icons.arrow_forward, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),

          // Sticky Action Button pinned to bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: GestureDetector(
                  onTap: () async {
                    if (_selectedStatusIndex == -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a status first'),
                        ),
                      );
                      return;
                    }
                    if (_selectedStatusIndex == 0) {
                      // Opens camera ONLY for 'Task Completed' state
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CameraScreen(),
                        ),
                      );
                      if (result != null && result['captured'] == true) {
                        // Check in as volunteer when task photo is taken
                        final loc = result['location'];
                        if (loc != null) {
                          HeatMapApiService.volunteerCheckin(
                            latitude: loc.latitude,
                            longitude: loc.longitude,
                            volunteerId: 'aura_volunteer_1',
                            reportId: widget.issue?['id'],
                          );
                        }
                        if (!mounted) return;
                        final surveyResult = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SurveyScreen(
                              issue: widget.issue,
                              timeTaken: _formatTime(),
                              capturedImagePath: result['path'],
                            ),
                          ),
                        );
                        if (surveyResult == true) {
                          widget.onClose?.call();
                        }
                      }
                    } else {
                      widget.onClose?.call(); // Just close for other states
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: _getButtonColor(),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: _getButtonColor().withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _getButtonText(),
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolunteerItem(String name, IconData? icon, {bool isMe = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (icon != null) Icon(icon, size: 20, color: Colors.black54),
        ],
      ),
    );
  }

  Widget _buildStatusCircle(int index, Color color) {
    bool isSelected = _selectedStatusIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatusIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.black, width: 2) : null,
        ),
      ),
    );
  }
}

class _VerticalRibbedGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Recreating the sophisticated vertical ribbed pattern from the image
    // Each rib has a smooth light-to-shadow gradient
    const double ribWidth = 26.0;
    final int count = (size.width / ribWidth).ceil();

    for (int i = 0; i < count; i++) {
      final double x = i * ribWidth;
      final Rect rect = Rect.fromLTWH(x, 0, ribWidth, size.height);

      final Paint paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.15), // Smooth highlight
            Colors.white.withValues(alpha: 0.05), // Mid-tone
            Colors.black.withValues(alpha: 0.03), // Soft shadow edge
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(rect);

      canvas.drawRect(rect, paint);

      // Add a very subtle vertical highlight line at the peak of the rib
      final Paint linePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
