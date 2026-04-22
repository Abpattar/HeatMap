import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart'; // import the home screen for navigation
import 'onboarding_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = false;

  Widget _buildTextField(String hintText, {bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        obscureText: isPassword,
        style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(fontSize: 16, color: Colors.black54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildSocialButton(Widget icon) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Center(child: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Painting
          Image.network(
            'https://images.unsplash.com/photo-1543857778-c4a1a3e0b2eb?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80', // Street painting style
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.blueGrey),
          ),
          
          // Diagonal Green Overlay
          CustomPaint(
            painter: DiagonalOverlayPainter(),
            size: Size.infinite,
          ),
          
          // Form Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100), // Push down to match mockup
                  
                  // Headlines
                  Text(
                    _isLogin ? "Welcome Back" : "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      _isLogin 
                        ? "Sign in to continue improving your community"
                        : "Create an account so you can start improving your community",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600, // Matches dark visible text
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Inputs
                  _buildTextField("Email"),
                  const SizedBox(height: 20),
                  _buildTextField("Password", isPassword: true),
                  
                  const SizedBox(height: 30),
                  
                  // Sign Up Action
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        // If Sign In, go straight to Main App
                        if (_isLogin) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        } else {
                          // If Sign Up, go to Onboarding flow
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA5F48A), // Light lime green matching
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black26,
                      ),
                      child: Text(
                        _isLogin ? "Sign In" : "Sign Up",
                        style: GoogleFonts.inter(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Toggle Link
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin ? "Don't have an account? " : "Already have an account? ",
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: _isLogin ? "Sign Up" : "Sign In",
                            style: GoogleFonts.inter(color: const Color(0xFFA5F48A), fontWeight: FontWeight.bold, fontSize: 13),
                          )
                        ]
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Social Login Section
                  Text(
                    "Or continue with",
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Logo using network image
                      _buildSocialButton(
                        Image.network(
                          'https://cdn-icons-png.flaticon.com/512/2991/2991148.png', 
                          width: 26, 
                          height: 26,
                          errorBuilder: (c,e,s) => const Icon(Icons.g_mobiledata, size: 40, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Facebook Native Icon
                      _buildSocialButton(
                        const Icon(Icons.facebook, size: 30, color: Colors.black),
                      ),
                      const SizedBox(width: 20),
                      // Apple Native Icon
                      _buildSocialButton(
                        const Icon(Icons.apple, size: 32, color: Colors.black),
                      ),
                    ],
                  ),
                  
                  // Add bottom padding to allow scrolling if needed on small screens
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Match the gradient style shown: top right is slightly tealish green, bottom left is dark olive green
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6AD39E).withValues(alpha: 0.85), // Soft teal/emerald transparency
          const Color(0xFF4C7D2D).withValues(alpha: 0.95), // Deep olive green
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
      
    final path = Path();
    path.moveTo(0, 0); // Top-left
    path.lineTo(size.width * 0.95, 0); // Along the top, almost to right edge
    path.lineTo(size.width * 0.15, size.height); // Down to the bottom, shifted slightly right
    path.lineTo(0, size.height); // Back to bottom-left
    path.close(); // Back to top-left
    
    // An additional thin solid dark green line along the border!
    // The mockup seems to have a hard dark green edge.
    final borderPaint = Paint()
      ..color = const Color(0xFF456B27).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
      
    canvas.drawPath(path, paint);
    
    // Draw the diagonal boundary stroke specifically
    canvas.drawLine(
      Offset(size.width * 0.95, 0),
      Offset(size.width * 0.15, size.height),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
