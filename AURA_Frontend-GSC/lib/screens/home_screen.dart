import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../widgets/bottom_nav_bar.dart';
import '../widgets/heatmap_view.dart';
import '../widgets/kpi_card.dart';
import '../widgets/stacked_cards.dart';
import 'issues_screen.dart';
import 'recent_tasks_screen.dart';
import 'report_screen.dart';
import 'groups_screen.dart';
import 'profile_screen.dart';
import '../widgets/ngo_detail_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isNavbarVisible = true;
  final ValueNotifier<double> _panelSlideNotifier = ValueNotifier<double>(0.0);
  final PanelController _panelController = PanelController();
  bool _isVolunteerMode = false;
  bool _isScrollLocked = false;

  // Key to send commands to the home-tab HeatMap iframe
  final GlobalKey<HeatMapViewState> _homeMapKey = GlobalKey<HeatMapViewState>();
  
  late AnimationController _gradientController;
  late Animation<Alignment> _alignmentTop;
  late Animation<Alignment> _alignmentBottom;

  // Live report count from heatmap
  int _liveReportCount = 0;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _alignmentTop = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.topRight,
    ).animate(_gradientController);

    _alignmentBottom = Tween<Alignment>(
      begin: Alignment.bottomRight,
      end: Alignment.bottomLeft,
    ).animate(_gradientController);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  void _handlePanelDragUpdate(double deltaY) {
    final double travel = MediaQuery.of(context).size.height - 450;
    if (travel <= 0) return;
    double newPos = _panelSlideNotifier.value - (deltaY / travel);
    _panelController.animatePanelToPosition(newPos.clamp(0.0, 1.0), duration: Duration.zero);
  }

  void _handlePanelDragEnd() {
    if (_panelSlideNotifier.value > 0.5) {
      _panelController.open();
    } else {
      _panelController.close();
    }
  }

  /// Handle messages from the HeatMap iframe
  void _onHeatMapMessage(String action, Map<String, dynamic> data) {
    if (action == 'reports_updated') {
      if (mounted) {
        setState(() {
          _liveReportCount = data['count'] ?? 0;
        });
      }
    } else if (action == 'more_info' || action == 'report_focused') {
      // A map popup button was tapped → switch to Issues tab
      setState(() => _currentIndex = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(),
          IssuesScreen(
            onToggleNavbar: (visible) {
              setState(() {
                _isNavbarVisible = visible;
              });
            },
          ),
          const ReportScreen(),
          const GroupsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _isNavbarVisible 
        ? CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          )
        : const SizedBox.shrink(),
    );
  }

  Widget _buildHomeContent() {
    return Stack(
      children: [
        // 1. Background HeatMap (replaces GoogleMap)
        Positioned.fill(
          child: ValueListenableBuilder<double>(
            valueListenable: _panelSlideNotifier,
            builder: (context, slide, child) {
              return Opacity(
                opacity: (1.0 - slide * 1.5).clamp(0.0, 1.0),
                child: child,
              );
            },
            child: RepaintBoundary(
              child: HeatMapView(
                key: _homeMapKey,
                onMessage: _onHeatMapMessage,
              ),
            ),
          ),
        ),

        // 2. Mode Toggle
        Positioned(
          top: 55,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isVolunteerMode = !_isVolunteerMode;
                  });
                  // Notify the home-tab map iframe of the mode change
                  _homeMapKey.currentState?.setMode(_isVolunteerMode);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 42,
                  width: 180,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        alignment: _isVolunteerMode ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          width: 86,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'Citizen',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: !_isVolunteerMode ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Volunteer',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _isVolunteerMode ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 3. Sliding Up Panel
        SlidingUpPanel(
          controller: _panelController,
          minHeight: 450,
          maxHeight: MediaQuery.of(context).size.height,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          backdropEnabled: true,
          backdropOpacity: 0.1,
          isDraggable: false, // Restricted to handle region (top 20%)
          color: Colors.transparent,
          onPanelSlide: (position) {
            _panelSlideNotifier.value = position;
          },
          header: GestureDetector(
            onVerticalDragUpdate: (details) => _handlePanelDragUpdate(details.delta.dy),
            onVerticalDragEnd: (details) => _handlePanelDragEnd(),
            behavior: HitTestBehavior.translucent,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.2, // Draggable Top 20%
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(38),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          panelBuilder: (sc) => _buildPanelContent(sc),
          body: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPanelContent(ScrollController sc) {
    try {
      if (!_gradientController.isAnimating && !_gradientController.isCompleted) {
        _gradientController.repeat(reverse: true);
      }
    } catch (e) {
      return Container(color: const Color(0xFFE5F8ED));
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_gradientController, _panelSlideNotifier]),
      builder: (context, child) {
        final slide = _panelSlideNotifier.value;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _alignmentTop.value,
                    end: _alignmentBottom.value,
                    colors: slide < 0.2 
                      ? [
                          const Color(0xFFDCFCE7),
                          const Color(0xFFBBF7D0),
                          const Color(0xFF86EFAC),
                        ]
                      : [
                          const Color(0xFFFEFCE8),
                          const Color(0xFFE5F8ED),
                        ],
                  ),
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    Colors.white.withValues(alpha: 0.1),
                    BlendMode.overlay,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: sc,
                  physics: _isScrollLocked 
                      ? const NeverScrollableScrollPhysics() 
                      : const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      ?child, 
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Stack(
            children: [
              ValueListenableBuilder<double>(
                valueListenable: _panelSlideNotifier,
                builder: (context, slide, _) {
                  return Opacity(
                    opacity: (1 - slide * 1.5).clamp(0.0, 1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Good Morning ',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF064E3B),
                              ),
                            ),
                            const Text('☀️', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Text(
                          'Abhinav',
                          style: GoogleFonts.poppins(
                            fontSize: 44,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF064E3B),
                            height: 1.1,
                            letterSpacing: -1.2,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
              ValueListenableBuilder<double>(
                valueListenable: _panelSlideNotifier,
                builder: (context, slide, _) {
                  return Opacity(
                    opacity: (slide * 2 - 0.7).clamp(0.0, 1.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Your\nCommunity',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Builder(
                          builder: (context) {
                            final double smoothValue = Curves.easeOutCubic.transform(slide.clamp(0.0, 1.0));
                            return Transform.translate(
                              offset: Offset((1 - smoothValue) * 40, 0),
                              child: Transform.scale(
                                scale: 0.85 + (smoothValue * 0.15),
                                child: Container(
                                  width: 95,
                                  height: 95,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      )
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFF0ea5e9).withValues(alpha: 0.15),
                                            const Color(0xFF10b981).withValues(alpha: 0.2),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '$_liveReportCount',
                                              style: GoogleFonts.poppins(
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                                color: const Color(0xFF064E3B),
                                              ),
                                            ),
                                            Text(
                                              'Active',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF064E3B).withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                  );
                }
              ),
            ],
          ),

          const SizedBox(height: 32),
          
          ValueListenableBuilder<double>(
            valueListenable: _panelSlideNotifier,
            builder: (context, slide, _) {
              if (slide >= 0.5) return const SizedBox.shrink();
              return Opacity(
                opacity: (1 - slide * 2).clamp(0.0, 1.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: StackedKpiCards(
                        key: const ValueKey('stacked_kpi_cards'),
                        onSwipeStart: () {
                          if (!_isScrollLocked) setState(() => _isScrollLocked = true);
                        },
                        onSwipeEnd: () {
                          if (_isScrollLocked) setState(() => _isScrollLocked = false);
                        },
                        cards: [
                          CardData(
                            isAlert: true,
                            title: 'BetterRoads NGO',
                            subtitle: 'Requires your help',
                            badgeText: '1 Task pending',
                            icon: Icons.warning_amber_rounded,
                            onTap: () => _showNgoDetail(
                              context,
                              'BetterRoads NGO',
                              'Infrastructure',
                              '4.8',
                              const Color(0xFF8B4B4B),
                              Icons.warning_amber_rounded,
                            ),
                          ),
                          CardData(
                            isAlert: true,
                            title: 'CleanCity NGO',
                            subtitle: 'Street cleanup required',
                            badgeText: '2 Tasks pending',
                            icon: Icons.cleaning_services_sharp,
                            onTap: () => _showNgoDetail(
                              context,
                              'CleanCity NGO',
                              'Environment',
                              '4.5',
                              const Color(0xFF4A3434),
                              Icons.cleaning_services_sharp,
                            ),
                          ),
                          CardData(
                            isAlert: true,
                            title: 'GreenEarth NGO',
                            subtitle: 'Tree plantation update',
                            badgeText: 'New',
                            icon: Icons.eco_outlined,
                            onTap: () => _showNgoDetail(
                              context,
                              'GreenEarth NGO',
                              'Sustainability',
                              '4.9',
                              const Color(0xFF1E3A2B),
                              Icons.eco_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: KpiCard(
                        isAlert: false,
                        title: 'Recent\nTasks',
                        icon: Icons.chat_bubble_outline,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RecentTasksScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          ),

          ValueListenableBuilder<double>(
            valueListenable: _panelSlideNotifier,
            builder: (context, slide, _) {
              if (slide <= 0.4) return const SizedBox.shrink();
              return Opacity(
                opacity: (slide * 2 - 0.8).clamp(0.0, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Events',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E3A2B),
                          ),
                        ),
                        Text(
                          'See More',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF22C55E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: GestureDetector(
                        onVerticalDragStart: (_) {}, 
                        onVerticalDragUpdate: (_) {}, 
                        child: Listener(
                          onPointerMove: (event) {
                            if (!_isScrollLocked) {
                              // More eager lock for swiping
                              if (event.delta.dx.abs() > event.delta.dy.abs() && event.delta.dx.abs() > 1.0) {
                                setState(() => _isScrollLocked = true);
                              }
                            }
                          },
                          onPointerUp: (_) {
                            if (_isScrollLocked) {
                              setState(() => _isScrollLocked = false);
                            }
                          },
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildEventCard(
                                '12/05/2026',
                                'Recycling Workshop',
                                'Come join us',
                                const Color(0xFF063B33),
                              ),
                              const SizedBox(width: 16),
                              _buildEventCard(
                                '15/05/2026',
                                'Park Cleanup',
                                'Helping nature',
                                const Color(0xFF22C55E),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      'Community',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E3A2B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCommunityFeedCard(
                      '13/05/2026',
                      'Society Run',
                      'Ran 5 Km',
                      'assets/images/group_hero.jpeg',
                    ),
                    const SizedBox(height: 16),
                    _buildCommunityFeedCard(
                      '23/04/2026',
                      'Food camp',
                      'Helped kids receive their meals',
                      'assets/images/group_hero.jpeg',
                    ),
                  ],
                ),
              );
            }
          ),
          
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildEventCard(String date, String title, String subtitle, Color color) {
    return Container(
      width: 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -30,
            child: RotationTransition(
              turns: const AlwaysStoppedAnimation(15 / 360),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 40,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE68A),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const Spacer(),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeedCard(String date, String title, String subtitle, String imagePath) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.45), BlendMode.darken),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            date,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showNgoDetail(BuildContext context, String title, String subtitle, String rating, Color color, IconData logo) {
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

}
