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
  // ── Map control ────────────────────────────────────────────────────────────
  final GlobalKey<HeatMapViewState> _mapKey = GlobalKey<HeatMapViewState>();

  // ── Panel / UI state ───────────────────────────────────────────────────────
  bool _showIssueInfo = false;
  bool _isAssigningTask = false;
  Map<String, dynamic>? _selectedIssue;
  Map<String, dynamic>? _activeProblemIssue;

  double _panelPosition = 0.0;
  bool _isScrollLocked = false;
  final PanelController _panelController = PanelController();
  late final PageController _pageController;

  // ── Live data from Firebase via map ───────────────────────────────────────
  List<Map<String, dynamic>> _liveReports = [];

  // ── Search / filter state  ─────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  String _activeCategory = 'all';

  static const _categories = [
    {'key': 'all',     'icon': '📍', 'label': 'All'},
    {'key': 'Flood',   'icon': '🌊', 'label': 'Flood'},
    {'key': 'Fire',    'icon': '🔥', 'label': 'Fire'},
    {'key': 'Medical', 'icon': '🏥', 'label': 'Medical'},
    {'key': 'Shelter', 'icon': '🏠', 'label': 'Shelter'},
    {'key': 'Food',    'icon': '🍲', 'label': 'Food'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: 501,
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ── Map → Flutter messages ─────────────────────────────────────────────────
  void _onMapMessage(String action, Map<String, dynamic> data) {
    switch (action) {
      case 'reports_updated':
        // Firebase reports arrived — populate the real issue list
        final reports = data['reports'];
        if (reports is List && mounted) {
          setState(() {
            _liveReports = reports
                .map((r) => Map<String, dynamic>.from(r as Map))
                .toList();
          });
        }
        break;

      case 'more_info':
        // User tapped "More Info" on a map popup → open issue detail panel
        final report = data['report'];
        if (report is Map && mounted) {
          final issue = Map<String, dynamic>.from(report);
          _onIssueSelected(issue, fromMap: true);
        }
        break;

      case 'report_focused':
        // A search result was clicked in the map → open its detail panel
        final report = data['report'];
        if (report is Map && mounted) {
          final issue = Map<String, dynamic>.from(report)
            ..putIfAbsent('id', () => data['id']);
          _onIssueSelected(issue, fromMap: true);
        }
        break;

      case 'location_update':
        // Could use to sort by distance — no-op for now
        break;
    }
  }

  // ── Flutter → Map: search ─────────────────────────────────────────────────
  void _onSearchChanged() {
    _mapKey.currentState?.search(_searchController.text);
  }

  // ── Flutter → Map: filter ─────────────────────────────────────────────────
  void _onCategorySelected(String cat) {
    setState(() => _activeCategory = cat);
    _mapKey.currentState?.filterByCategory(cat);
    Navigator.of(context).pop(); // close bottom sheet
  }

  // ── Issue selection ────────────────────────────────────────────────────────
  void _onIssueSelected(Map<String, dynamic> issue, {bool fromMap = false}) {
    setState(() {
      _selectedIssue = issue;
      _showIssueInfo = true;
    });
    widget.onToggleNavbar?.call(false);

    // If triggered from Flutter card, also tell the map to focus that pin
    if (!fromMap) {
      final id = issue['id'] as String?;
      if (id != null) _mapKey.currentState?.highlightReport(id);
    }

    _panelController.animatePanelToPosition(0.8,
        duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
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
    _panelController.animatePanelToPosition(newPos.clamp(0.0, 1.0),
        duration: Duration.zero);
  }

  void _handlePanelDragEnd() {
    if (_panelPosition > 0.5) {
      _panelController.open();
    } else {
      _panelController.close();
    }
  }

  // ── Derived issue list (merge live + fallback) ─────────────────────────────
  List<Map<String, dynamic>> get _displayedReports {
    final live = _liveReports
        .where((r) =>
            _activeCategory == 'all' || r['category'] == _activeCategory)
        .toList();
    if (live.isNotEmpty) return live;
    // Fallback hardcoded list while Firebase loads
    return [
      {'id': '', 'title': 'Potholes',           'distance': '2km away', 'level': 3, 'reporter': 'Aditya B',  'lat': 12.9735, 'lng': 77.5900},
      {'id': '', 'title': 'Garbage',             'distance': '4km away', 'level': 1, 'reporter': 'Abhinav',   'lat': 12.9720, 'lng': 77.5950},
      {'id': '', 'title': 'Broken Bench',        'distance': '6km away', 'level': 2, 'reporter': 'Apu',       'lat': 12.9710, 'lng': 77.5890},
      {'id': '', 'title': 'Water Pipeline Leak', 'distance': '3km away', 'level': 3, 'reporter': 'Rahul',     'lat': 12.9720, 'lng': 77.5950},
    ];
  }

  String _reportTitle(Map<String, dynamic> r) =>
      (r['title'] ?? r['problem'] ?? r['category'] ?? 'Issue') as String;

  String _reportDistance(Map<String, dynamic> r) =>
      (r['distance'] ?? '-- away') as String;

  int _reportLevel(Map<String, dynamic> r) {
    final sev = r['level'] ?? r['severity'] ?? 1;
    return (sev is int) ? sev : (sev as num).toInt();
  }

  String _reportReporter(Map<String, dynamic> r) =>
      (r['reporter'] ?? r['reported_by'] ?? 'Unknown') as String;

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── HeatMap as permanent background ──────────────────────────────────
        if (_activeProblemIssue == null)
          Positioned.fill(
            child: HeatMapView(
              key: _mapKey,
              onMessage: _onMapMessage,
            ),
          ),

        // ── Dynamic Header (Search & Title OR Close Button) ───────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                _showIssueInfo ? _buildIssueInfoHeader() : _buildMainHeader(),
          ),
        ),

        // ── Conditionally render SlidingUpPanel or ProblemSolvingScreen ────────
        if (_activeProblemIssue == null) ...[
          SlidingUpPanel(
            controller: _panelController,
            minHeight: _showIssueInfo ? 480 : 420,
            maxHeight: _showIssueInfo
                ? (MediaQuery.of(context).size.height * 0.72).clamp(480, 1000)
                : MediaQuery.of(context).size.height * 0.72,
            isDraggable: false,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            backdropEnabled: false,
            color: Colors.transparent,
            onPanelSlide: (position) {
              setState(() {
                _panelPosition = position;
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
                _isScrollLocked = false;
              });
            },
            panelBuilder: (sc) =>
                _showIssueInfo ? _buildIssueInfoContent(sc) : _buildPanelContent(sc),
            header: GestureDetector(
              onVerticalDragUpdate: (details) =>
                  _handlePanelDragUpdate(details.delta.dy),
              onVerticalDragEnd: (details) => _handlePanelDragEnd(),
              behavior: HitTestBehavior.translucent,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.2,
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
          Positioned.fill(
            child: ProblemSolvingScreen(
              issue: _activeProblemIssue,
              onClose: () {
                // Resolve the report on the map when task completed
                final id = _activeProblemIssue?['id'] as String?;
                if (id != null && id.isNotEmpty) {
                  _mapKey.currentState?.resolveReport(id);
                }
                setState(() => _activeProblemIssue = null);
                widget.onToggleNavbar?.call(true);
              },
            ),
          ),
        ],
      ],
    );
  }

  // ── Overlay ────────────────────────────────────────────────────────────────
  void _showAssignmentOverlay() {
    setState(() => _isAssigningTask = true);

    // Tell the map the task is being accepted
    final id = _selectedIssue?['id'] as String?;
    if (id != null && id.isNotEmpty) {
      _mapKey.currentState?.acceptTask(id);
    }

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: TaskAssignmentOverlay(
              onComplete: () {
                Navigator.of(context).pop();
                setState(() {
                  _activeProblemIssue = _selectedIssue;
                  _isAssigningTask = false;
                  _showIssueInfo = false;
                });
                widget.onToggleNavbar?.call(false);
              },
            ),
          );
        },
      ),
    );
  }

  // ── Headers ────────────────────────────────────────────────────────────────
  Widget _buildMainHeader() {
    final activeCat = _categories.firstWhere(
      (c) => c['key'] == _activeCategory,
      orElse: () => _categories.first,
    );

    return Container(
      key: const ValueKey('main_header'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E3A2B).withValues(alpha: 0.95),
            const Color(0xFF1E3A2B).withValues(alpha: 0.50),
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
                  // ── Search bar wired to the map ─────────────────────────
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
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.inter(
                                color: Colors.black87,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search issues on map…',
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                _mapKey.currentState?.search('');
                              },
                              child: Icon(Icons.close,
                                  size: 18, color: Colors.grey[400]),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ── Category filter button wired to the map ─────────────
                  GestureDetector(
                    onTap: _showCategorySheet,
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _activeCategory == 'all'
                            ? const Color(0xFFF0F9FF)
                            : const Color(0xFF064E3B),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          activeCat['icon']!,
                          style: const TextStyle(fontSize: 22),
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

  // ── Category bottom sheet ──────────────────────────────────────────────────
  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Filter by Category',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E3A2B),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final active = _activeCategory == cat['key'];
                  return GestureDetector(
                    onTap: () => _onCategorySelected(cat['key']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0xFF064E3B)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(25),
                        border: active
                            ? null
                            : Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat['icon']!,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 6),
                          Text(
                            cat['label']!,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color:
                                  active ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Issue info panel content (detail view) ─────────────────────────────────
  Widget _buildIssueInfoContent(ScrollController sc) {
    final issue = _selectedIssue ?? {};
    final title = _reportTitle(issue);
    final location = (issue['location_name'] ?? 'Unknown location') as String;
    final severity = _reportLevel(issue);
    final helping = (issue['people_accepted'] ?? 0) as int;
    final description = (issue['description'] ?? '') as String;
    final category = (issue['category'] ?? '') as String;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5F86C), Color(0xFFE5F8ED)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                controller: sc,
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.poppins(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1E3A2B),
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    location,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: severity >= 7
                                          ? Colors.red
                                          : severity >= 4
                                              ? Colors.orange
                                              : Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'SEV $severity',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (category.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  category,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Hero(
                          tag: 'issue_image',
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image,
                                    size: 36, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        _statChip(Icons.people, '$helping helping'),
                        const SizedBox(width: 10),
                        _statChip(Icons.bar_chart, 'Severity $severity/10'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    if (description.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Text(
                          'You will be part of a team that will reach the site and address this issue.',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Sticky Slide to Accept
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1E3A2B)),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E3A2B),
              )),
        ],
      ),
    );
  }

  // ── Panel list content ────────────────────────────────────────────────────
  Widget _buildPanelContent(ScrollController sc) {
    final reports = _displayedReports;

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE5F86C), Color(0xFFE5F8ED)],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Stack(
          children: [
            // CAROUSEL (collapsed)
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
                                      '${reports.length} active issues',
                                      style: GoogleFonts.poppins(
                                        fontSize: 22,
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
                                child: const Icon(Icons.location_on,
                                    color: Colors.red, size: 30),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 180,
                          child: Listener(
                            onPointerMove: (event) {
                              if (!_isScrollLocked) {
                                if (event.delta.dx.abs() >
                                        event.delta.dy.abs() &&
                                    event.delta.dx.abs() > 1.0) {
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
                                if (reports.isEmpty) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                final r = reports[index % reports.length];
                                return Padding(
                                  padding:
                                      const EdgeInsets.only(left: 24, right: 8),
                                  child: IssueCard(
                                    title: _reportTitle(r),
                                    distance: _reportDistance(r),
                                    level: _reportLevel(r),
                                    reporterName: _reportReporter(r),
                                    avatarUrl: '',
                                    imageUrl: '',
                                    onTap: () => _onIssueSelected(r),
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

            // LIST VIEW (expanded)
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
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 32),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Active Issues',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '${reports.length} found',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E3A2B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (reports.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Text(
                                'Loading issues from Firebase…',
                                style: GoogleFonts.inter(
                                    color: Colors.grey[500]),
                              ),
                            ),
                          )
                        else
                          ...reports.map((r) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: IssueCard(
                                  title: _reportTitle(r),
                                  distance: _reportDistance(r),
                                  level: _reportLevel(r),
                                  reporterName: _reportReporter(r),
                                  avatarUrl: '',
                                  imageUrl: '',
                                  onTap: () => _onIssueSelected(r),
                                ),
                              )),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BOTTOM GRADIENT
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
