import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SlideToAcceptButton extends StatefulWidget {
  final String text;
  final VoidCallback onAccept;
  final bool isProcessing;
  final String processingText;

  const SlideToAcceptButton({
    super.key,
    required this.text,
    required this.onAccept,
    this.isProcessing = false,
    this.processingText = 'Assigning Task',
  });

  @override
  State<SlideToAcceptButton> createState() => _SlideToAcceptButtonState();
}

class _SlideToAcceptButtonState extends State<SlideToAcceptButton> with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isAccepted = false;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxDrag = constraints.maxWidth - 60; // 60 is the diameter of the handle

        return Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: widget.isProcessing == true ? Colors.white : null,
            gradient: widget.isProcessing == true 
              ? null 
              : const LinearGradient(
                colors: [
                  Color(0xFF22C55E),
                  Color(0xFF4ADE80),
                ],
              ),
          ),
          child: Stack(
            children: [
              // Background Text
              Center(
                child: Opacity(
                  opacity: widget.isProcessing == true ? 1.0 : (1.0 - (_dragValue / maxDrag)).clamp(0.0, 1.0),
                  child: Text(
                    widget.isProcessing == true ? widget.processingText : widget.text,
                    style: GoogleFonts.inter(
                      color: widget.isProcessing == true ? const Color(0xFF1E3A2B) : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Draggable Handle
              if (widget.isProcessing != true)
                Positioned(
                  left: _dragValue,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      if (_isAccepted) return;
                      setState(() {
                        _dragValue += details.delta.dx;
                        _dragValue = _dragValue.clamp(0.0, maxDrag);
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_isAccepted) return;
                      if (_dragValue >= maxDrag * 0.9) {
                        setState(() {
                          _dragValue = maxDrag;
                          _isAccepted = true;
                        });
                        widget.onAccept();
                      } else {
                        setState(() {
                          _dragValue = 0.0;
                        });
                      }
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(2, 0),
                          ),
                        ],
                      ),
                      child: AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                //
                                // Tasks for Problem Solving Screen implementation:
                                // - [x] Integrate Animation with Hero <!-- id: 7 -->
                                // - [x] Wrap image in `Hero` widget <!-- id: 8 -->
                                // - [x] Implement transparent route for `TaskAssignmentOverlay` <!-- id: 9 -->
                                // - [x] Implement Problem Solving Screen <!-- id: 10 -->
                                //     - [x] Create `ProblemSolvingScreen` widget <!-- id: 11 -->
                                //     - [x] Implement checklist and background UI <!-- id: 12 -->
                                //     - [x] Implement timer and status indicators <!-- id: 13 -->
                                //     - [x] Implement sliding panel with volunteer list and help button <!-- id: 14 -->
                                //     - [x] Add navigation from `TaskAssignmentOverlay` <!-- id: 15 -->
                                // - [x] Verification <!-- id: 16 -->
                                //     - [x] Fix NaN rendering error <!-- id: 17 -->
                                //     - [x] Fix KPI card overflow <!-- id: 18 -->
                                //
                                // Glowing background for the icon
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF22C55E).withValues(alpha: _glowController.value * 0.2),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: const Color(0xFF22C55E),
                                  size: 20 + (_glowController.value * 2), // Subtle scale effect
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              
              // Locked Circle for Processing State
              if (widget.isProcessing == true)
                Positioned(
                  right: 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(-2, 0),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
