// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Web implementation — embeds the HeatMap frontend in an iframe via HtmlElementView.
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
    ui_web.platformViewRegistry.registerViewFactory('heatmap-iframe',
        (int viewId) {
      _iframe = html.IFrameElement()
        ..src = 'heatmap.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..allow = 'geolocation'
        ..setAttribute('allowfullscreen', 'true');
      return _iframe!;
    });
  }

  void _listenForMessages() {
    _messageSub = html.window.onMessage.listen((event) {
      try {
        if (event.data is String) {
          final data = jsonDecode(event.data as String);
          if (data is Map<String, dynamic> && data.containsKey('action')) {
            widget.onMessage?.call(
              data['action'] as String,
              data,
            );
          }
        }
      } catch (_) {
        // Ignore non-JSON messages
      }
    });
  }

  /// Highlight a specific report on the map by ID.
  void highlightReport(String id) {
    _iframe?.contentWindow?.postMessage(
      jsonEncode({'action': 'goToReport', 'id': id}),
      '*',
    );
  }

  /// Filter map pins by category.
  void filterByCategory(String category) {
    _iframe?.contentWindow?.postMessage(
      jsonEncode({'action': 'filterCategory', 'category': category}),
      '*',
    );
  }

  /// Center the map on specific coordinates.
  void centerMap(double lat, double lng, [int zoom = 14]) {
    _iframe?.contentWindow?.postMessage(
      jsonEncode({'action': 'centerMap', 'lat': lat, 'lng': lng, 'zoom': zoom}),
      '*',
    );
  }

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
