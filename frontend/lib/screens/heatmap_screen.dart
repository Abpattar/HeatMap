import 'package:flutter/material.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import '../widgets/stats_panel.dart';
import '../widgets/filter_bar.dart';

// ── JS interop — calls window.setHeatMapFilter() defined in index.html ──
@JS('setHeatMapFilter')
external void _jsSetFilter(JSString category);

class HeatMapScreen extends StatefulWidget {
  const HeatMapScreen({super.key});

  @override
  State<HeatMapScreen> createState() => _HeatMapScreenState();
}

class _HeatMapScreenState extends State<HeatMapScreen> {
  String _activeFilter = 'all';
  int _totalReports = 0;
  int _redZones = 0;
  int _yellowZones = 0;
  int _greenZones = 0;
  int _ghostZones = 0;
  bool _showGhostHeat = true;

  @override
  void initState() {
    super.initState();
    _startStatsPolling();
  }

  void _startStatsPolling() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _readStats();
      _startStatsPolling();
    });
  }

  void _readStats() {
    try {
      final el = web.document.getElementById('stats-data');
      if (el == null) return;

      final text = el.textContent ?? '';
      if (text.isEmpty) return;

      final total = _extractInt(text, 'total');
      final red = _extractInt(text, 'red');
      final yellow = _extractInt(text, 'yellow');
      final green = _extractInt(text, 'green');
      final ghost = _extractInt(text, 'ghost');

      if (mounted) {
        setState(() {
          _totalReports = total;
          _redZones = red;
          _yellowZones = yellow;
          _greenZones = green;
          _ghostZones = ghost;
        });
      }
    } catch (_) {}
  }

  int _extractInt(String json, String key) {
    final regex = RegExp('"$key":(\\d+)');
    final match = regex.firstMatch(json);
    return match != null ? int.tryParse(match.group(1) ?? '0') ?? 0 : 0;
  }

  void _applyFilter(String filter) {
    setState(() => _activeFilter = filter);
    try {
      _jsSetFilter(filter.toJS);
    } catch (_) {}
  }

  void _toggleGhostHeat() {
    setState(() => _showGhostHeat = !_showGhostHeat);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Top App Bar ──────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _buildTopBar(),
          ),

          // ── Stats Panel (top right) ──────────────────────────────────
          Positioned(
            top: 70, right: 12,
            child: StatsPanel(
              total: _totalReports,
              red: _redZones,
              yellow: _yellowZones,
              green: _greenZones,
              ghost: _ghostZones,
            ),
          ),

          // ── Filter Bar (bottom) ──────────────────────────────────────
          Positioned(
            bottom: 20, left: 12, right: 12,
            child: FilterBar(
              activeFilter: _activeFilter,
              onFilterChanged: _applyFilter,
            ),
          ),

          // ── Ghost Heat Toggle (bottom right) ─────────────────────────
          Positioned(
            bottom: 90, right: 12,
            child: _buildGhostToggle(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.85),
            Colors.black.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Logo / Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.85),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.whatshot, color: Colors.white, size: 20),
                SizedBox(width: 6),
                Text(
                  'HeatMap',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 8),
                SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Total count badge
          if (_totalReports > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_totalReports Active Reports',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGhostToggle() {
    return GestureDetector(
      onTap: _toggleGhostHeat,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _showGhostHeat
                ? Colors.purple.withOpacity(0.7)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.blur_on,
              color: _showGhostHeat ? Colors.purpleAccent : Colors.grey,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              'Ghost Heat',
              style: TextStyle(
                color: _showGhostHeat ? Colors.purpleAccent : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
