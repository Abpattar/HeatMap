import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// REST API client for the HeatMap FastAPI backend.
class HeatMapApiService {
  // Default to the Vercel-deployed backend; change for local dev.
  static const String _baseUrl = 'https://heat-map-ashy.vercel.app';
  static final _uuid = Uuid();

  /// POST /report — Create a new report (pin on the map).
  static Future<Map<String, dynamic>?> createReport({
    required double latitude,
    required double longitude,
    required int severity,
    String? category,
    String? problem,
    String? locationName,
    String? volunteerId,
  }) async {
    try {
      final reportId = _uuid.v4();
      final body = {
        'report_id': reportId,
        'latitude': latitude,
        'longitude': longitude,
        'severity': severity,
        'category': category ?? 'General',
        'problem': problem ?? category ?? 'Reported Issue',
        'location_name': locationName,
        'volunteer_id': volunteerId,
      };
      body.removeWhere((key, value) => value == null);

      final response = await http.post(
        Uri.parse('$_baseUrl/report'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// POST /accept_task — Volunteer accepts a task.
  static Future<bool> acceptTask({
    required String reportId,
    required String volunteerId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/accept_task'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'report_id': reportId,
          'volunteer_id': volunteerId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// POST /checkin — Volunteer checks in at a report location.
  static Future<bool> volunteerCheckin({
    required double latitude,
    required double longitude,
    required String volunteerId,
    String? reportId,
  }) async {
    try {
      final body = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'volunteer_id': volunteerId,
      };
      if (reportId != null) body['report_id'] = reportId;

      final response = await http.post(
        Uri.parse('$_baseUrl/checkin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// GET /reports — Get all active (unresolved) reports.
  static Future<List<Map<String, dynamic>>> getActiveReports() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/reports'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['reports'] != null) {
          return List<Map<String, dynamic>>.from(data['reports']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// GET /reports/ghost — Get ghost heat zones.
  static Future<List<Map<String, dynamic>>> getGhostHeat() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/reports/ghost'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['ghost_zones'] != null) {
          return List<Map<String, dynamic>>.from(data['ghost_zones']);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
