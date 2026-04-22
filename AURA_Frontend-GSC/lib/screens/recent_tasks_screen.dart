import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentTasksScreen extends StatelessWidget {
  const RecentTasksScreen({super.key});

  static final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Pothole Repair',
      'location': 'MG Road, 2km away',
      'level': 'LEVEL 3',
      'levelColor': Colors.redAccent,
      'reporter': 'Aditya B',
      'completedDate': 'Apr 12, 2026',
      'xp': '+120 XP',
      'imageUrl': 'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
    },
    {
      'title': 'Garbage Cleanup',
      'location': 'Koramangala, 1.4km away',
      'level': 'LEVEL 2',
      'levelColor': Colors.orange,
      'reporter': 'Meera S',
      'completedDate': 'Apr 10, 2026',
      'xp': '+80 XP',
      'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
    },
    {
      'title': 'Broken Streetlight',
      'location': 'Indiranagar, 3.2km away',
      'level': 'LEVEL 1',
      'levelColor': Colors.green,
      'reporter': 'Kiran M',
      'completedDate': 'Apr 8, 2026',
      'xp': '+60 XP',
      'imageUrl': 'https://images.unsplash.com/photo-1516912481808-3406841bd33c?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
    },
    {
      'title': 'Flooded Road',
      'location': 'Whitefield, 5km away',
      'level': 'LEVEL 4',
      'levelColor': Colors.red,
      'reporter': 'Ravi T',
      'completedDate': 'Apr 5, 2026',
      'xp': '+200 XP',
      'imageUrl': 'https://images.unsplash.com/photo-1547683905-f686c993aae5?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
    },
    {
      'title': 'Tree Plantation Drive',
      'location': 'Cubbon Park, 0.8km away',
      'level': 'LEVEL 2',
      'levelColor': Colors.orange,
      'reporter': 'Sneha J',
      'completedDate': 'Apr 1, 2026',
      'xp': '+100 XP',
      'imageUrl': 'https://images.unsplash.com/photo-1444492417251-9c84a5fa18e0?ixlib=rb-1.2.1&auto=format&fit=crop&w=200&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE5F8ED),
              Color(0xFF86EFAC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, size: 22, color: Color(0xFF1E3A2B)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Recent Tasks',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E3A2B),
                      ),
                    ),
                    const Spacer(),
                    // Total XP Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '560 XP Total',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  '${_tasks.length} tasks completed',
                  style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4A7A5A), fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 16),

              // Task List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return _TaskCard(task: task);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4EC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06), width: 1),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'],
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        task['location'],
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: task['levelColor'],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          task['level'],
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Reporter row
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black87,
                        child: Icon(Icons.person, color: Colors.white, size: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Reported by\n${task['reporter']}',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Date + XP Row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.black45),
                      const SizedBox(width: 4),
                      Text(
                        task['completedDate'],
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          task['xp'],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF166534),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Right: Image + Stamp
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    task['imageUrl'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.image, color: Colors.grey, size: 36),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -8,
                  left: -20,
                  right: -10,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green[50]!.withValues(alpha: 0.95),
                        border: Border.all(color: Colors.green[600]!, width: 2.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "COMPLETED",
                            style: GoogleFonts.inter(
                              fontSize: 10, color: Colors.green[700],
                              fontWeight: FontWeight.w900, letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(Icons.check_circle, color: Colors.green[600], size: 11),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
