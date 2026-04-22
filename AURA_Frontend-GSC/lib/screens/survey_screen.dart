import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/slide_to_accept_button.dart';
import 'camera_screen.dart';
import 'task_completed_screen.dart';

class SurveyScreen extends StatefulWidget {
  final Map<String, dynamic>? issue;
  final String timeTaken;
  final String? capturedImagePath;

  const SurveyScreen({
    super.key,
    this.issue,
    required this.timeTaken,
    this.capturedImagePath,
  });

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  // Survey state
  int _q1Val = 0; // 0: None, 1: Yes, 2: No
  int _q2Val = 0;
  int _q3Val = 0;
  final List<String> _selectedVolunteers = [];
  final List<String> _availableVolunteers = ["Sarah M.", "Rahul T.", "Aditya B.", "Abhinav", "Apu", "John D."];

  final List<String> _additionalPhotos = [];
  bool _isConverting = false;

  Future<void> _takeAdditionalPhoto() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
    if (result != null && result['captured'] == true && result['path'] != null) {
      if (mounted) {
        setState(() {
          _additionalPhotos.add(result['path']);
        });
      }
    }
  }

  void _onSlideComplete() async {
    setState(() => _isConverting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    // Push the animated completion screen
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const TaskCompletedScreen()),
    );
    
    // Pop back to problem solving screen after the animated screen is done
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _buildTogglePill(int value, Function(int) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE5F8ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                color: value == 1 ? const Color(0xFF22C55E) : Colors.transparent,
              ),
              child: Text(
                "Yes",
                style: GoogleFonts.inter(
                  color: value == 1 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: Colors.black12),
          GestureDetector(
            onTap: () => onChanged(2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
                color: value == 2 ? Colors.redAccent : Colors.transparent,
              ),
              child: Text(
                "No",
                style: GoogleFonts.inter(
                  color: value == 2 ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionRow(String question, Widget actionWidget) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              question,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: actionWidget,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient matching the design
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF537651).withValues(alpha: 0.9), // Dark green at top
                    Colors.white, // Fades to white
                    Colors.grey.shade100,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),
          ),
          // Adding a subtle striping effect (optional, simplified here)
          Positioned.fill(
            child: Row(
              children: List.generate(
                6,
                (index) => Expanded(
                  child: Container(
                    color: index.isEven ? Colors.white.withValues(alpha: 0.04) : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // App Bar Area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        
                        // Header: Title and Map Inset
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title & Reporter
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.issue?['title'] ?? 'Potholes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F5A29), // Deep green title
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 18,
                                        backgroundColor: Colors.black87,
                                        child: Icon(Icons.pets, color: Colors.white, size: 16), // Example cat avatar
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Reported by\nAditya B',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                            height: 1.2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Map & Issue Image Stack
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: Stack(
                                children: [
                                  // Map Background
                                  Positioned(
                                    top: 0, right: 0,
                                    child: Container(
                                      width: 110,
                                      height: 110,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                                        image: const DecorationImage(
                                          image: NetworkImage('https://images.unsplash.com/photo-1526778548025-fa2f459cd5ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Original Issue Image
                                  Positioned(
                                    bottom: 0, left: 0,
                                    child: Container(
                                      width: 65,
                                      height: 65,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E),
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'https://images.unsplash.com/photo-1599420186946-7b6fb4e297f0?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Time Taken
                        Text(
                          'Time taken',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF277A42),
                          ),
                        ),
                        Text(
                          widget.timeTaken,
                          style: GoogleFonts.poppins(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            height: 1.1,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Survey Questions
                        _buildQuestionRow(
                          "Was the task\nfully completed", 
                          _buildTogglePill(_q1Val, (v) => setState(() => _q1Val = v))
                        ),
                        
                        _buildQuestionRow(
                          "Did all the assigned\nvolunteers take part", 
                          _buildTogglePill(_q2Val, (v) => setState(() => _q2Val = v))
                        ),
                        
                        // Volunteer Selector - Show only if "No" (2) selected
                        if (_q2Val == 2) 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Selected Volunteers Pills
                                if (_selectedVolunteers.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _selectedVolunteers.map((name) => Chip(
                                        backgroundColor: const Color(0xFFE5F8ED),
                                        padding: const EdgeInsets.all(4),
                                        label: Text(
                                          name,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E3A2B),
                                          ),
                                        ),
                                        onDeleted: () {
                                          setState(() {
                                            _selectedVolunteers.remove(name);
                                          });
                                        },
                                        deleteIconColor: Colors.redAccent,
                                      )).toList(),
                                    ),
                                  ),
                                
                                // Dropdown Selector
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                                      hint: Row(
                                        children: [
                                          CircleAvatar(radius: 14, backgroundColor: Colors.grey.shade300, child: const Icon(Icons.person, size: 18, color: Colors.white)),
                                          const SizedBox(width: 12),
                                          Text("Select missing volunteers", style: GoogleFonts.inter(color: Colors.black54, fontSize: 14)),
                                        ],
                                      ),
                                      items: _availableVolunteers.where((v) => !_selectedVolunteers.contains(v)).map((name) {
                                        return DropdownMenuItem<String>(
                                          value: name,
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 14, 
                                                backgroundColor: Colors.grey[200],
                                                child: Text(name[0], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                                              ),
                                              const SizedBox(width: 12),
                                              Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 14)),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            _selectedVolunteers.add(newValue);
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        
                        _buildQuestionRow(
                          "Was the NGO/Community\nhelpful for resources", 
                          _buildTogglePill(_q3Val, (v) => setState(() => _q3Val = v))
                        ),
                        
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Comments",
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: TextField(
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: "Add your feedback here...",
                                  hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 14),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 300), // Space for bottom panel
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Container
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 60),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFFAFFAB), // Yellowish
                    const Color(0xFFCCFF45), // Bright lime
                  ],
                ),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photos',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Photos Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Captured Image Box
                        if (widget.capturedImagePath != null)
                          Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF16A34A), width: 2, style: BorderStyle.solid), // Green border, actually dashed in design but solid works
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                ? Image.network(widget.capturedImagePath!, fit: BoxFit.cover)
                                : Image.file(File(widget.capturedImagePath!), fit: BoxFit.cover),
                            ),
                          ),
                          
                        // Dynamically added photos
                        ..._additionalPhotos.map((path) => Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF16A34A), width: 2, style: BorderStyle.solid),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: kIsWeb
                              ? Image.network(path, fit: BoxFit.cover)
                              : Image.file(File(path), fit: BoxFit.cover),
                          ),
                        )),
                        
                        // Add Photo Dashed Box
                        GestureDetector(
                          onTap: _takeAdditionalPhoto,
                          child: Container(
                             width: 80,
                             height: 80,
                             decoration: BoxDecoration(
                               color: Colors.white.withValues(alpha: 0.3),
                               borderRadius: BorderRadius.circular(12),
                               border: Border.all(color: const Color(0xFF16A34A), width: 2), // Mocking dashed by simple border
                             ),
                             child: const Center(
                               child: Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
                             ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Slide to Accept - Task Completion
                  SlideToAcceptButton(
                    text: 'Complete task',
                    isProcessing: _isConverting,
                    processingText: 'Task report submitting...',
                    onAccept: _onSlideComplete,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
