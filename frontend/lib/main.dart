import 'package:flutter/material.dart';
import 'screens/heatmap_screen.dart';

void main() {
  runApp(const HeatMapApp());
}

class HeatMapApp extends StatelessWidget {
  const HeatMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeatMap — Emergency Response',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF4444),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HeatMapScreen(),
    );
  }
}
