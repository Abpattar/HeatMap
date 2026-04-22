import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../widgets/heatmap_view.dart';
import '../widgets/issue_card.dart';
import '../widgets/slide_to_accept_button.dart';
import '../widgets/task_assignment_overlay.dart';
import 'problem_solving_screen.dart';

class IssuesScreen extends StatefulWidget {
  final Function(bool)? onToggleNavbar;

  const IssuesScreen({
    super.key,
    this.onToggleNavbar,
  });

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  bool _showIssueInfo = false;
  bool _isAssigningTask = false;
  Map<String, dynamic>? _selectedIssue;
  Map<String, dynamic>? _activeProblemIssue;
  
  double _panelPosition = 0.0;
  bool _isScrollLocked = false;
  final PanelController _panelController = PanelController();
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85, 
      initialPage: 501, // Large enough for "infinite" feel, starting at a multiple of 3
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onIssueSelected(Map<String, dynamic> issue) {
    setState(() {
      _selectedIssue = issue;
      _showIssueInfo = true;
    });
    widget.onToggleNavbar?.call(false);
    
    // Smoothly expand the panel to show the details if it was collapsed
    _panelController.animatePanelToPosition(0.8, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
  }

  void _onBackToList() {
    setState(() {
      _showIssueInfo = false;
      _selectedIssue = null;
    });
    widget.onToggleNavbar?.call(true);
  }

  void _handlePanelDragUpdate(double deltaY) {
    final double currentMinHeight = _showIssueInfo ? 480 : 420;
    final double currentMaxHeight = _showIssueInfo 
        ? (MediaQuery.of(context).size.height * 0.72).clamp(480, 1000) 
        : MediaQuery.of(context).size.height * 0.72;
    final double travel = currentMaxHeight - currentMinHeight;
    if (travel <= 0) return;

    double newPos = _panelPosition - (deltaY / travel);
    _panelController.animatePanelToPosition(newPos.clamp(0.0, 1.0), duration: Duration.zero);
  }

  void _handlePanelDragEnd() {
    if (_panelPosition > 0.5) {
      _panelController.open();
    } else {
      _panelController.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // HeatMap as permanent background (Hidden during problem solving)
        if (_activeProblemIssue == null)
          const Positioned.fill(
            child: HeatMapView(),
          ),

        // Dynamic Header (Search & Title OR Close Button)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _showIssueInfo ? _buildIssueInfoHeader() : _buildMainHeader(),
          ),
        ),

        // Conditionally render either the SlidingUpPanel or ProblemSolvingScreen
        if (_activeProblemIssue == null) ...[
          // Sliding Panel with Carousel and List
          SlidingUpPanel(
            controller: _panelController,
            minHeight: _showIssueInfo ? 480 : 420,
            maxHeight: _showIssueInfo 
                ? (MediaQuery.of(context).size.height * 0.72).clamp(480, 1000) 
                : MediaQuery.of(context).size.height * 0.72,
            isDraggable: false, // Restricted to handle region (top 20%)
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            backdropEnabled: false,
            color: Colors.transparent,
            onPanelSlide: (position) {
              setState(() {
                _panelPosition = position;
                // Force unlock if panel is moving significantly
                if (_isScrollLocked && position > 0.05) {
                  _isScrollLocked = false;
                }
              });
            },
            onPanelClosed: () {
              setState(() {
                _panelPosition = 0.0;
                _isScrollLocked = false;
              });
            },
            onPanelOpened: () {
              setState(() {
                _panelPosition = 1.0;
                _isScrollLocked = false; // Reset lock on open
              });
            },
            panelBuilder: (sc) => _showIssueInfo ? _buildIssueInfoContent(sc) : _buildPanelContent(sc),
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
            body: const SizedBox(),
          ),
        ] else ...[
          // Problem Solving View (Integrated)
          Positioned.fill(
            child: ProblemSolvingScreen(
              issue: _activeProblemIssue,
              onClose: () {
                setState(() {
                  _activeProblemIssue = null;
                });
                widget.onToggleNavbar?.call(true); // Bring back navbar
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showAssignmentOverlay() {
    setState(() {
      _isAssigningTask = true;
    });

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: TaskAssignmentOverlay(
              onComplete: () {
                Navigator.of(context).pop(); // Close overlay route
                
                setState(() {
                  _activeProblemIssue = _selectedIssue;
                  _isAssigningTask = false;
                  _showIssueInfo = false; // Hide the info panel
                });

                widget.onToggleNavbar?.call(false); // Hide navbar during problem solving
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainHeader() {
    return Container(
      key: const ValueKey('main_header'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E3A2B).withValues(alpha: 0.95), // Deep Dark Green
            const Color(0xFF1E3A2B).withValues(alpha: 0.50), // Fading Green
            Colors.transparent,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Issues in your\nCommunity',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[400]),
                          const SizedBox(width: 12),
                          Text(
                            'Search for Issues Nearby',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.tune, color: Colors.green),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueInfoHeader() {
    return SafeArea(
      key: const ValueKey('info_header'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: GestureDetector(
            onTap: _onBackToList,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Color(0xFF1E3A2B)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssueInfoContent(ScrollController sc) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE5F86C),
              Color(0xFFE5F8ED),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Scrollable Content
            Positioned.fill(
              child: SafeArea(
                top: false,
                bottom: false,
                child: SingleChildScrollView(
                  controller: sc,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 140), // Reduced top padding from 32 to 20
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title, Subtitle, Badge and Image (Horizontal Row)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedIssue?['title'] ?? 'Potholes',
                                  style: GoogleFonts.poppins(
                                    fontSize: 44,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF1E3A2B),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      '2km away',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'LEVEL 3',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Issue Image with Green Border
                          Hero(
                            tag: 'issue_image',
                            child: Container(
                              width: 120,
                              height: 120,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Reporter Info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black,
                            child: const Icon(Icons.person, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reported by',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                'Aditya B',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Description Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You will be part of a team that will reach the site and make sure to cover the pothole',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'All supplies will be available at community center',
                              style: GoogleFonts.inter(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Sticky Slide to Accept Button Area with Gradient
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFFE5F8ED),
                      const Color(0xFFE5F8ED).withAlpha(150),
                      const Color(0xFFE5F8ED).withAlpha(0),
                    ],
                    stops: const [0.0, 0.7, 1.0],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 60),
                child: SlideToAcceptButton(
                  text: 'Slide to Accept Task',
                  isProcessing: _isAssigningTask,
                  onAccept: _showAssignmentOverlay,
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildPanelContent(ScrollController sc) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE5F86C),
            Color(0xFFE5F8ED),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 1. CAROUSEL VIEW (Visible when collapsed)
            Visibility(
              visible: _panelPosition < 0.6,
              child: Opacity(
                opacity: (1.0 - (_panelPosition * 2.5)).clamp(0.0, 1.0),
                child: IgnorePointer(
                  ignoring: _panelPosition > 0.4,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carousel Header
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Issues in your community',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E3A2B),
                                      ),
                                    ),
                                    Text(
                                      'Origin Harmony Grooves\nLayout',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Horizontal carousel
                        SizedBox(
                          height: 180,
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
                            child: PageView.builder(
                              padEnds: false,
                              controller: _pageController,
                              itemCount: 999,
                              itemBuilder: (context, index) {
                                final issues = [
                                  {'title': 'Potholes', 'reporter': 'Aditya B', 'level': 3},
                                  {'title': 'Garbage', 'reporter': 'Abhinav', 'level': 1},
                                  {'title': 'Broken Bench', 'reporter': 'Apu', 'level': 2},
                                ];
                                final itemIndex = index % issues.length;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 24, right: 8),
                                  child: IssueCard(
                                    title: issues[itemIndex]['title'] as String,
                                    distance: '2km away',
                                    level: issues[itemIndex]['level'] as int,
                                    reporterName: issues[itemIndex]['reporter'] as String,
                                    avatarUrl: '',
                                    imageUrl: '',
                                    onTap: () => _onIssueSelected({'title': issues[itemIndex]['title'], 'lat': 12.9735, 'lng': 77.5900}),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. LIST VIEW (Full issues list, visible when expanded)
            Visibility(
              visible: _panelPosition > 0.2,
              child: Opacity(
                opacity: ((_panelPosition - 0.35) * 2.5).clamp(0.0, 1.0),
                child: IgnorePointer(
                  ignoring: _panelPosition < 0.5,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                      if (mounted) setState(() {});
                    },
                    color: const Color(0xFF1E3A2B),
                    backgroundColor: Colors.white,
                    child: ListView(
                      controller: sc,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'New Issues',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'See More',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E3A2B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        IssueCard(
                          title: 'Potholes',
                          distance: '2km away',
                          level: 3,
                          reporterName: 'Aditya B',
                          avatarUrl: '',
                          imageUrl: '',
                          onTap: () => _onIssueSelected({'title': 'Potholes', 'lat': 12.9735, 'lng': 77.5900}),
                        ),
                        const SizedBox(height: 16),
                        IssueCard(
                          title: 'Garbage',
                          distance: '4km away',
                          level: 1,
                          reporterName: 'Abhinav',
                          avatarUrl: '',
                          imageUrl: '',
                          onTap: () => _onIssueSelected({'title': 'Garbage', 'lat': 12.9720, 'lng': 77.5950}),
                        ),
                        const SizedBox(height: 16),
                        IssueCard(
                          title: 'Park benches broken',
                          distance: '6km away',
                          level: 2,
                          reporterName: 'Apu',
                          avatarUrl: '',
                          imageUrl: '',
                          onTap: () => _onIssueSelected({'title': 'Park benches broken', 'lat': 12.9710, 'lng': 77.5890}),
                        ),
                        const SizedBox(height: 16),
                        IssueCard(
                          title: 'Water Pipeline Leak',
                          distance: '3km away',
                          level: 3,
                          reporterName: 'Rahul',
                          avatarUrl: '',
                          imageUrl: '',
                          onTap: () => _onIssueSelected({'title': 'Water Pipeline Leak', 'lat': 12.9720, 'lng': 77.5950}),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 3. BOTTOM SMOOTH GRADIENT
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFE5F8ED).withValues(alpha: 0),
                        const Color(0xFFE5F8ED).withValues(alpha: 0.8),
                        const Color(0xFFE5F8ED),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
