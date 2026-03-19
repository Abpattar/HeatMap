import 'package:flutter/material.dart';

class FilterBar extends StatelessWidget {
  final String activeFilter;
  final Function(String) onFilterChanged;

  const FilterBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  static const filters = [
    {'label': 'All', 'value': 'all', 'icon': '🌐', 'color': Color(0xFF90CAF9)},
    {'label': 'Medical', 'value': 'Medical', 'icon': '🏥', 'color': Color(0xFFEF5350)},
    {'label': 'Flood', 'value': 'Flood', 'icon': '🌊', 'color': Color(0xFF42A5F5)},
    {'label': 'Fire', 'value': 'Fire', 'icon': '🔥', 'color': Color(0xFFFF7043)},
    {'label': 'Shelter', 'value': 'Shelter', 'icon': '🏠', 'color': Color(0xFF66BB6A)},
    {'label': 'Food', 'value': 'Food', 'icon': '🍱', 'color': Color(0xFFFFCA28)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'FILTER BY CATEGORY',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((f) {
                final isActive = activeFilter == f['value'];
                final color = f['color'] as Color;
                return GestureDetector(
                  onTap: () => onFilterChanged(f['value'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isActive ? color.withOpacity(0.25) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? color : Colors.white.withOpacity(0.15),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(f['icon'] as String, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          f['label'] as String,
                          style: TextStyle(
                            color: isActive ? color : Colors.white54,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
