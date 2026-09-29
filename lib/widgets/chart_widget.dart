// lib/widgets/chart_widget.dart

import 'package:flutter/material.dart';
import 'package:student_productivity_tracker/themes/app_theme.dart';

class ChartWidget extends StatelessWidget {
  final List<double> values;
  final List<String> labels;

  const ChartWidget({
    super.key,
    required this.values,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final double maxValue =
    values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Weekly Progress",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final double height =
                    (values[index] / maxValue) * 160;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 24,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        labels[index],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}