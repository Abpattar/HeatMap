import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/ngo_detail_overlay.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  void _showNGODetail(BuildContext context, {
    required String title,
    required String subtitle,
    required String rating,
    required Color color,
    required IconData logo,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NgoDetailOverlay(
        title: title,
        subtitle: subtitle,
        rating: rating,
        color: color,
        logo: logo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Artistic Header Section
            Stack(
              children: [
                // Background Image/Illustration (Using high-quality artistic park scene)
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/group_hero.jpeg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                // Gradient Overlay for readability
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.3),
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.4),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                // Text and Figure Overlay
                Positioned(
                  top: 60,
                  left: 24,
                  right: 24,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // 3D Groups Figures Illustration
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildFigure(Colors.orange[400]!, -15),
                              Positioned(left: 30, child: _buildFigure(Colors.blue[400]!, 0)),
                              Positioned(left: 15, bottom: -5, child: _buildFigure(Colors.orange[600]!, 0)),
                            ],
                          ),
                          const SizedBox(width: 60), // Space for figures
                          Expanded(
                            child: Text(
                              'Groups &\nOrganizations',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.1,
                                shadows: [
                                  Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 2)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                      // Quote
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          width: 220,
                          child: Text(
                            '"Alone we can do so little; together we can do so much." — Helen Keller',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFF064E3B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. Discover NGOs Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Discover NGO\'s and Groups',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF064E3B),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Search Bar & Filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search for NGO\'s Nearby',
                          prefixIcon: Icon(Icons.search, color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.settings_input_composite, color: Color(0xFF34D399)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Horizontal NGO List (Carousel with 4 cards)
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  GestureDetector(
                    onTap: () => _showNGODetail(
                      context,
                      title: 'Better Roads NGO',
                      subtitle: 'Road and Pathway fixing Ngo organization',
                      rating: '4.6',
                      color: const Color(0xFF166534),
                      logo: Icons.auto_fix_high,
                    ),
                    child: _buildNGOCard(
                      title: 'Better Roads NGO',
                      subtitle: 'Road and Pathway fixing\nNgo organization',
                      rating: '4.6',
                      color: const Color(0xFF166534),
                      logo: Icons.auto_fix_high,
                      width: 160,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showNGODetail(
                      context,
                      title: 'Clean Water Org',
                      subtitle: 'Water safety and supply maintenance',
                      rating: '4.8',
                      color: const Color(0xFF065F46),
                      logo: Icons.water_drop,
                    ),
                    child: _buildNGOCard(
                      title: 'Clean Water Org',
                      subtitle: 'Water safety and supply\nmaintenance',
                      rating: '4.8',
                      color: const Color(0xFF065F46),
                      logo: Icons.water_drop,
                      width: 160,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showNGODetail(
                      context,
                      title: 'Urban Foresters',
                      subtitle: 'Urban greenery and tree planting initiatives',
                      rating: '4.7',
                      color: const Color(0xFF15803D),
                      logo: Icons.forest,
                    ),
                    child: _buildNGOCard(
                      title: 'Urban Foresters',
                      subtitle: 'Urban greenery and tree\nplanting initiatives',
                      rating: '4.7',
                      color: const Color(0xFF15803D),
                      logo: Icons.forest,
                      width: 160,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showNGODetail(
                      context,
                      title: 'Animal Save Org',
                      subtitle: 'Animal welfare and street rescue operations',
                      rating: '4.9',
                      color: const Color(0xFF3F6212),
                      logo: Icons.pets,
                    ),
                    child: _buildNGOCard(
                      title: 'Animal Save Org',
                      subtitle: 'Animal welfare and street\nrescue operations',
                      rating: '4.9',
                      color: const Color(0xFF3F6212),
                      logo: Icons.pets,
                      width: 160,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 3. Your Groups Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Your Groups',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF064E3B),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Horizontal Your Groups List
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  GestureDetector(
                    onTap: () => _showNGODetail(
                      context,
                      title: 'CleanCity NGO',
                      subtitle: 'Street cleanup and waste management',
                      rating: '4.9',
                      color: const Color(0xFF065F46),
                      logo: Icons.cleaning_services_sharp,
                    ),
                    child: _buildNGOCard(
                      title: 'CleanCity NGO',
                      subtitle: 'Street cleanup and\nwaste management',
                      rating: '4.9',
                      color: const Color(0xFF065F46),
                      logo: Icons.cleaning_services_sharp,
                      width: 150,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showNGODetail(
                      context,
                      title: 'GreenEarth NGO',
                      subtitle: 'Tree plantation and urban greenery',
                      rating: '4.7',
                      color: const Color(0xFF15803D),
                      logo: Icons.eco_outlined,
                    ),
                    child: _buildNGOCard(
                      title: 'GreenEarth NGO',
                      subtitle: 'Tree plantation and\nurban greenery',
                      rating: '4.7',
                      color: const Color(0xFF15803D),
                      logo: Icons.eco_outlined,
                      width: 150,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => _showNGODetail(
                      context,
                      title: 'Road Safety Org',
                      subtitle: 'Traffic awareness and road maintenance',
                      rating: '4.5',
                      color: const Color(0xFF3F6212),
                      logo: Icons.traffic_outlined,
                    ),
                    child: _buildNGOCard(
                      title: 'Road Safety Org',
                      subtitle: 'Traffic awareness and\nroad maintenance',
                      rating: '4.5',
                      color: const Color(0xFF3F6212),
                      logo: Icons.traffic_outlined,
                      width: 150,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120), // Padding for navbar
          ],
        ),
      ),
    );
  }

  Widget _buildNGOCard({
    required String title,
    required String subtitle,
    required String rating,
    required Color color,
    required IconData logo,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(logo, size: 24, color: color),
              ),
              Row(
                children: [
                  Text(
                    rating,
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Icon(Icons.star, color: Colors.orange, size: 16),
                ],
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white70,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFigure(Color color, double rotate) {
    return Transform.rotate(
      angle: rotate * 3.14 / 180,
      child: Container(
        width: 35,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
      ),
    );
  }
}
