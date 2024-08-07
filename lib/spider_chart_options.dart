import 'package:flutter/material.dart';

class SpiderChartOptions {
  /// Color of inner lines
  final Color gridColor;

  /// Color of outer border
  final Color borderColor;

  /// Minimum value of the chart
  final double maxValue;

  /// Whether to adjust the radius of the chart to fit the labels
  final bool adjustRadius;

  const SpiderChartOptions({
    this.maxValue = 5,
    this.gridColor = Colors.grey,
    this.borderColor = Colors.grey,
    this.adjustRadius = true,
  });
}