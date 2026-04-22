import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'level_up_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Artistic Arched Header Section
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Sky Background with Arch
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/group_hero.jpeg'), // Reusing the high-quality sky image
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(200, 50),
                      bottomRight: Radius.elliptical(200, 50),
                    ),
                  ),
                ),
                // Gradient Overlay to blend
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.2),
                        const Color(0xFFE5F8ED).withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                ),
                // Badges Path (Conceptual Arch)
                Positioned(
                  top: 60,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // The Arch Line
                        CustomPaint(
                          size: const Size(double.infinity, 100),
                          painter: ArchPainter(),
                        ),
                        // Badges
                        _buildBadge(Icons.star, Colors.amber, -120, 20),
                        _buildBadge(Icons.emoji_events, Colors.orange, 0, -10, size: 50),
                        _buildBadge(Icons.workspace_premium, Colors.brown, 120, 20),
                      ],
                    ),
                  ),
                ),
                // Profile Picture (Overlap)
                Positioned(
                  bottom: -60,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LevelUpScreen()),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E), // Progress Border Color
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 65,
                              backgroundColor: Color(0xFFE5F8ED),
                              backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Abhinav'), 
                            ),
                          ),
                        ),
                        // Level Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            'LVL 12',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),

            // 2. Profile Details & Settings
            Stack(
              children: [
                // Background with Stripes
                Positioned.fill(
                  child: Container(
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
                    child: CustomPaint(
                      painter: StripePainter(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        'Account Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF064E3B),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('Username', 'S.Abhinav'),
                      const SizedBox(height: 16),
                      _buildTextField('Phone', '+44 555 5555 55'),
                      const SizedBox(height: 16),
                      _buildTextField('Email Address', 'example@example.com'),
                      const SizedBox(height: 24),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Push Notifications',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                          Switch(
                            value: _pushNotifications,
                            onChanged: (val) => setState(() => _pushNotifications = val),
                            activeThumbColor: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 5,
                              shadowColor: const Color(0xFF059669).withValues(alpha: 0.5),
                            ),
                            child: Text(
                              'Update Profile',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 120), // Navbar safety space
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF064E3B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF1E3A2B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, Color color, double x, double y, {double size = 35}) {
    return Transform.translate(
      offset: Offset(x, y),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }
}

class StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.02)
      ..strokeWidth = 1.5;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      x += 15;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
