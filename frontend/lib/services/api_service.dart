import 'package:http/http.dart' as http;

// ── API Service ────────────────────────────────────────────────────────────────
// Central place to manage all API calls to our FastAPI backend.
// Change baseUrl when deploying to production.

class ApiService {
  // Local dev URL — update this when deployed to Render/Railway
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ── Submit a new report ──────────────────────────────────────────────────────
  static Future<bool> submitReport({
    required double latitude,
    required double longitude,
    required int severity,
    String? category,
    String? reportId,
    String? volunteerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/report'),
        headers: {'Content-Type': 'application/json'},
        body: '''{
          "latitude": $latitude,
          "longitude": $longitude,
          "severity": $severity
          ${category != null ? ',"category": "$category"' : ''}
          ${reportId != null ? ',"report_id": "$reportId"' : ''}
          ${volunteerId != null ? ',"volunteer_id": "$volunteerId"' : ''}
        }''',
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Volunteer check-in ───────────────────────────────────────────────────────
  static Future<bool> volunteerCheckIn({
    required double latitude,
    required double longitude,
    required String volunteerId,
    String? reportId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        headers: {'Content-Type': 'application/json'},
        body: '''{
          "latitude": $latitude,
          "longitude": $longitude,
          "volunteer_id": "$volunteerId"
          ${reportId != null ? ',"report_id": "$reportId"' : ''}
        }''',
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Get active reports ───────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getActiveReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));
      if (response.statusCode == 200) {
        // Basic parsing — upgrade to dart:convert later if needed
        return [];
      }
    } catch (_) {}
    return [];
  }
}
