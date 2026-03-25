import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Vercel monorepo routes /api/* → FastAPI backend
  // Replace YOUR_VERCEL_APP with your actual Vercel project name
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://heat-map-ten.vercel.app/api',
  );

  // ── Submit a new report ────────────────────────────────────────────────────
  static Future<bool> submitReport({
    required double latitude,
    required double longitude,
    required int severity,
    String? category,
    String? problem,
    String? locationName,
    String? reportId,
    String? volunteerId,
  }) async {
    try {
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'severity': severity,
        if (category != null) 'category': category,
        if (problem != null) 'problem': problem,
        if (locationName != null) 'location_name': locationName,
        if (reportId != null) 'report_id': reportId,
        if (volunteerId != null) 'volunteer_id': volunteerId,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Accept a task ──────────────────────────────────────────────────────────
  static Future<bool> acceptTask({
    required String reportId,
    required String volunteerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/accept_task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'report_id': reportId, 'volunteer_id': volunteerId}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Volunteer check-in ─────────────────────────────────────────────────────
  static Future<bool> volunteerCheckIn({
    required double latitude,
    required double longitude,
    required String volunteerId,
    String? reportId,
  }) async {
    try {
      final body = {
        'latitude': latitude,
        'longitude': longitude,
        'volunteer_id': volunteerId,
        if (reportId != null) 'report_id': reportId,
      };
      final response = await http.post(
        Uri.parse('$baseUrl/checkin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ── Get active reports ─────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getActiveReports() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(json['reports'] ?? []);
      }
    } catch (_) {}
    return [];
  }
}
