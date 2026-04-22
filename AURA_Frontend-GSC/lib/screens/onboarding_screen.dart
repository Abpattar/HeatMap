import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuart,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  Widget _buildTextField(String hint) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.black38, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: 54,
        height: 54,
        decoration: const BoxDecoration(
          color: Color(0xFF4EE2AE),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildPage1() {
    return Column(
      children: [
        // Image takes top portion
        Expanded(
          flex: 5,
          child: Image.network(
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (c, e, s) => Container(color: const Color(0xFF8BC4A8)),
          ),
        ),

        // Bottom sheet
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFD3F8B3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Info', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF2A4A30))),
                  const SizedBox(height: 4),
                  Text('Lets get to know you', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A9A80))),
                  const SizedBox(height: 20),

                  _buildTextField('Name'),
                  _buildTextField('Date of Birth'),

                  Row(
                    children: [
                      _genderIcon(Icons.male),
                      const SizedBox(width: 8),
                      _genderIcon(Icons.female),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Single", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                            Container(margin: const EdgeInsets.symmetric(horizontal: 10), width: 1, height: 14, color: Colors.black26),
                            Text("Married", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Align(alignment: Alignment.centerRight, child: _buildNextButton()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _genderIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: Icon(icon, size: 20, color: Colors.black87),
    );
  }

  Widget _buildPage2() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://images.unsplash.com/photo-1524661135-423995f22d0b?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: const Color(0xFF8BC4A8)),
              ),
              // Map inset
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                    image: const DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1526778548025-fa2f459cd5ce?ixlib=rb-1.2.1&auto=format&fit=crop&w=300&q=80'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFD3F8B3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Community', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF2A4A30))),
                const SizedBox(height: 4),
                Text("Find NGO's and issues of\nyour locality", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A9A80))),
                const SizedBox(height: 20),
                _buildTextField('Community Name/ Area'),
                _buildTextField('Address'),
                Align(alignment: Alignment.centerRight, child: _buildNextButton()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage3() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Image.network(
            'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (c, e, s) => Container(color: const Color(0xFF8BC4A8)),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFD3F8B3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How can You Help\nyour community', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2A4A30), height: 1.2)),
                  const SizedBox(height: 4),
                  Text('Lets get to know you', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A9A80))),
                  const SizedBox(height: 20),

                  _buildTextField('Profession'),
                  _buildTextField('Education'),

                  Text('Skills', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A9A80))),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip('Electrical'),
                        _buildChip('Carpentry'),
                        _buildChip('Plumbing'),
                        _buildChip('Special...'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Contribution', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A9A80))),
                  const SizedBox(height: 10),
                  _buildTextField('When can you contribute to service'),
                  SizedBox(
                    width: 120,
                    child: _buildTextField('Time'),
                  ),

                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: _buildNextButton()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage4() {
    return Column(
      children: [
        Expanded(
          flex: 5,
          child: Image.network(
            'https://images.unsplash.com/photo-1532629345422-7515f3d16bb6?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80',
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (c, e, s) => Container(color: const Color(0xFF8BC4A8)),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFD3F8B3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Be a part of\nChangemakers', style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: const Color(0xFF2A4A30), height: 1.2)),
                const SizedBox(height: 4),
                Text("Join your local NGO's and\nCommunities", style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF7A9A80))),
                const SizedBox(height: 20),
                _buildTextField('Search'),
                const Spacer(),
                Align(alignment: Alignment.centerRight, child: _buildNextButton()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          _buildPage1(),
          _buildPage2(),
          _buildPage3(),
          _buildPage4(),
        ],
      ),
    );
  }
}
