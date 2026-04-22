// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Web implementation — embeds the HeatMap frontend in an iframe via HtmlElementView.
/// In embedded mode the map hides its own search/filter/FAB UI so Flutter
/// is the single source of truth for those controls.
class HeatMapView extends StatefulWidget {
  final Function(String action, Map<String, dynamic> data)? onMessage;

  const HeatMapView({super.key, this.onMessage});

  @override
  State<HeatMapView> createState() => HeatMapViewState();
}

class HeatMapViewState extends State<HeatMapView> {
  static bool _registered = false;
  static html.IFrameElement? _iframe;
  StreamSubscription<html.MessageEvent>? _messageSub;

  @override
  void initState() {
    super.initState();
    _registerViewFactory();
    _listenForMessages();
  }

  void _registerViewFactory() {
    if (_registered) return;
    _registered = true;
    ui_web.platformViewRegistry.registerViewFactory(
      'heatmap-iframe',
      (int viewId) {
        _iframe = html.IFrameElement()
          // embedded=true tells heatmap.html to hide its own search/filter UI
          ..src = 'heatmap.html?embedded=true'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'geolocation'
          ..setAttribute('allowfullscreen', 'true');
        return _iframe!;
      },
    );
  }

  void _listenForMessages() {
    _messageSub = html.window.onMessage.listen((event) {
      try {
        if (event.data is String) {
          final data = jsonDecode(event.data as String);
          if (data is Map<String, dynamic> && data.containsKey('action')) {
            widget.onMessage?.call(
              data['action'] as String,
              Map<String, dynamic>.from(data),
            );
          }
        }
      } catch (_) {
        // Ignore non-JSON messages
      }
    });
  }

  // ── Low-level send ────────────────────────────────────────────────────────

  void _send(Map<String, dynamic> payload) {
    _iframe?.contentWindow?.postMessage(jsonEncode(payload), '*');
  }

  // ── Public API called by Flutter UI ──────────────────────────────────────

  /// Focus (fly to + open popup) a specific report by Firestore document ID.
  void highlightReport(String id) => _send({'action': 'goToReport', 'id': id});

  /// Apply a category filter on the map. Pass 'all' to clear.
  void filterByCategory(String category) =>
      _send({'action': 'filterCategory', 'category': category});

  /// Center the map on [lat]/[lng] at optional [zoom].
  void centerMap(double lat, double lng, [int zoom = 14]) =>
      _send({'action': 'centerMap', 'lat': lat, 'lng': lng, 'zoom': zoom});

  /// Search the map for [query] — highlights matching pins.
  void search(String query) => _send({'action': 'search', 'query': query});

  /// Switch between Citizen mode (all pins) and Volunteer mode (only critical).
  void setMode(bool isVolunteer) =>
      _send({'action': 'setMode', 'volunteer': isVolunteer});

  /// Tell the map a report was accepted / task started (so it updates status).
  void acceptTask(String id) => _send({'action': 'acceptTask', 'id': id});

  /// Tell the map a task is complete so the pin can be removed.
  void resolveReport(String id) => _send({'action': 'resolveReport', 'id': id});

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(viewType: 'heatmap-iframe');
  }
}
