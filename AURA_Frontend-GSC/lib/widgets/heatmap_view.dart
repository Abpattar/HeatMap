// Conditional export: picks web implementation when dart:html is available,
// otherwise falls back to a stub (placeholder) for mobile platforms.
export 'heatmap_view_stub.dart'
    if (dart.library.html) 'heatmap_view_web.dart';
