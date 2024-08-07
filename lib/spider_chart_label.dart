import 'package:flutter/material.dart';

class SpiderChartLabel {
  const SpiderChartLabel({
    required this.label,
    this.style = const TextStyle(color: Colors.black, fontSize: 12),
    this.maxWidth = double.infinity,
  });

  final String label;
  final TextStyle style;
  final double maxWidth;
}