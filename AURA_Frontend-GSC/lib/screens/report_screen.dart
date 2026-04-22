import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF6), // Light cream/minty background
      body: Column(
        children: [
          // 1. Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFD9F99D), // Lime green
                  const Color(0xFF86EFAC).withValues(alpha: 0.5), // Soft mint
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Report\nIssues in\nyour area',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                ),
                // 3D Clipboard Illustration (Placeholder using Icon/Image)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.assignment, size: 80, color: Color(0xFF166534)),
                  ),
                ),
              ],
            ),
          ),

          // 2. Categories Grid
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 20),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 30,
                children: [
                  _buildCategoryItem('Food', Icons.restaurant, const Color(0xFF064E3B)),
                  _buildCategoryItem('Transit', Icons.bus_alert, const Color(0xFF3FB113)),
                  _buildCategoryItem('Medicines', Icons.medication, const Color(0xFF4DB90E)),
                  _buildCategoryItem('Grocery', Icons.shopping_bag, const Color(0xFF4DB90E)),
                  _buildCategoryItem('Housing', Icons.vpn_key, const Color(0xFF4DB90E)),
                  _buildCategoryItem('Package', Icons.card_giftcard, const Color(0xFF4DB90E)),
                  _buildCategoryItem('Finance', Icons.monetization_on, const Color(0xFF4DB90E)),
                  _buildCategoryItem('Ticket', Icons.confirmation_number, const Color(0xFF4DB90E)),
                  _buildCategoryItem('Add', Icons.add, const Color(0xFF4DB90E)),
                ],
              ),
            ),
          ),

          // 3. Scan Button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFBEFCD5), // Light mint pill
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFF5A8964),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Scan Survey Papers',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E3A2B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
