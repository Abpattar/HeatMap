import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stub implementation for non-web platforms.
/// Shows a placeholder instead of the Leaflet map.
class HeatMapView extends StatelessWidget {
  final Function(String action, Map<String, dynamic> data)? onMessage;

  const HeatMapView({super.key, this.onMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 64, color: Color(0xFF64748B)),
            const SizedBox(height: 16),
            Text(
              'HeatMap (Web Only)',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Run on Chrome to see the live map',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// No-op on non-web platforms.
  void runJs(String js) {}

  /// No-op on non-web platforms.
  void highlightReport(String id) {}

  /// No-op on non-web platforms.
  void filterByCategory(String category) {}

  /// No-op on non-web platforms.
  void centerMap(double lat, double lng, [int zoom = 14]) {}
}
