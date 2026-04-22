import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: currentIndex,
      height: 75.0,
      items: [
        CurvedNavigationBarItem(
          child: const Icon(Icons.home_outlined, size: 30),
          label: 'Home',
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        CurvedNavigationBarItem(
          child: const Icon(Icons.search_outlined, size: 30),
          label: 'Issues',
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        CurvedNavigationBarItem(
          child: const Icon(Icons.camera_alt_outlined, size: 30),
          label: 'Report',
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        CurvedNavigationBarItem(
          child: const Icon(Icons.send_outlined, size: 30),
          label: 'Groups',
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        CurvedNavigationBarItem(
          child: const Icon(Icons.person_outline, size: 30),
          label: 'Profile',
          labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
      color: Colors.white,
      buttonBackgroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      animationCurve: Curves.easeInOutCubic,
      animationDuration: const Duration(milliseconds: 400),
      onTap: (index) => onTap(index),
      letIndexChange: (index) => true,
    );
  }
}
