import 'package:custom_painter_spider_chart/spider_chart_point.dart';
import 'package:flutter/material.dart';

class SpiderChartItem {
  const SpiderChartItem({
    required this.points,
    this.lineWidth = 2,
    this.fillColor = Colors.blue,
    this.borderColor = Colors.black,
  });

  final List<SpiderChartPoint> points;
  final double lineWidth;
  final Color fillColor;
  final Color borderColor;
}