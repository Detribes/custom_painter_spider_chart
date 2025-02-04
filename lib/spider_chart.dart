import 'package:custom_painter_spider_chart/spider_chart_item.dart';
import 'package:custom_painter_spider_chart/spider_chart_label.dart';
import 'package:custom_painter_spider_chart/spider_chart_options.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;


class SpiderChart extends StatelessWidget {
  final List<SpiderChartItem> data;
  final List<SpiderChartLabel>? labels;
  final SpiderChartOptions options;

  const SpiderChart({
    required this.data,
    this.options = const SpiderChartOptions(),
    this.labels,
    super.key,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: SpiderChartRender(
      data: data,
      options: options,
      labels: labels,
    ),
  );
}

class SpiderChartRender extends CustomPainter {
  final List<SpiderChartItem> data;
  final List<SpiderChartLabel>? labels;
  final SpiderChartOptions options;

  SpiderChartRender({
    required this.data,
    required this.options,
    this.labels,
  }) {
    assert(
    data.isNotEmpty && data.every((element) => element.points.length == data.first.points.length),
    'All data points must have the same length',
    );
    assert(
    data.first.points.length >= 3,
    'At least 3 data points are required',
    );
    assert(
    labels == null || labels!.length == data.first.points.length,
    'Labels must have the same length as data points',
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    const paddingFromVertex = 5;
    final center = Offset(size.width / 2, size.height / 2);
    final labelPainters = labels?.map((label) {
      final textPainter = TextPainter(
        text: TextSpan(text: label.label, style: label.style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: label.maxWidth);
      return textPainter;
    }).toList();

    var radius = size.shortestSide / 2;
    // Angle between vertices of the polygon
    final angle = 2 * math.pi / data.first.points.length;

    if (labelPainters != null && options.adjustRadius) {
      var overflow = 0.0;
      final sizeRect = Rect.fromLTWH(0, 0, size.width, size.height);

      // calculate label coordinates and find maximum overflow
      for (var i = 0; i < data.first.points.length; i++) {
        final textPainter = labelPainters[i];
        final textX = center.dx +
            (radius + textPainter.width / 2 + paddingFromVertex) *
                math.cos(i * angle - math.pi / 2);
        final textY = center.dy +
            (radius + textPainter.height / 2 + paddingFromVertex) * math.sin(i * angle - math.pi / 2);

        // find distance from starting coordinate to the edge of sizeRect

        // if it's in the right
        if (textX > sizeRect.center.dx) {
          final newOverflow = (textX + textPainter.width / 2 + paddingFromVertex) - sizeRect.right;
          overflow = math.max(overflow, newOverflow);
        }

        // if it's in the left
        if (textX < sizeRect.center.dx) {
          final newOverflow = -(textX - textPainter.width / 2 - paddingFromVertex);
          overflow = math.max(overflow, newOverflow);
        }

        if (textY > sizeRect.bottom) {
          final newOverflow = (textY + textPainter.height - sizeRect.bottom);
          overflow = math.max(overflow, newOverflow);
        }

        if (textY < sizeRect.top) {
          overflow = math.max(overflow, -(textY - paddingFromVertex));
        }
      }

      radius -= overflow;
    }

    // draw the outer border
    final outerBorderPath = Path();
    final outerBorderPaint = Paint()
      ..color = options.borderColor
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < data.first.points.length; i++) {
      final x = center.dx + radius * math.cos(i * angle - math.pi / 2);
      final y = center.dy + radius * math.sin(i * angle - math.pi / 2);
      if (i == 0) {
        outerBorderPath.moveTo(x, y);
      } else {
        outerBorderPath.lineTo(x, y);
      }

      if (labels != null) {
        final textPainter = labelPainters![i];
        final textX = center.dx +
            (radius + textPainter.width / 2 + paddingFromVertex) *
                math.cos(i * angle - math.pi / 2);
        final textY = center.dy +
            (radius + textPainter.height / 2 + paddingFromVertex) *
                math.sin(i * angle - math.pi / 2);

        textPainter.paint(
          canvas,
          Offset(textX - textPainter.width / 2, textY - textPainter.height / 2),
        );
      }
    }
    outerBorderPath.close();
    canvas.drawPath(outerBorderPath, outerBorderPaint);

    final gridPath = Path();
    final gridPaint = Paint()
      ..color = options.gridColor
      ..style = PaintingStyle.stroke;

    // draw inner lines from center to vertices
    for (var i = 0; i < data.first.points.length; i++) {
      final x = center.dx + radius * math.cos(i * angle - math.pi / 2);
      final y = center.dy + radius * math.sin(i * angle - math.pi / 2);
      gridPath.moveTo(center.dx, center.dy);
      gridPath.lineTo(x, y);
    }
    canvas.drawPath(gridPath, gridPaint);

    // draw maxValue inner polygons
    for (var i = 0; i < options.maxValue; i++) {
      final polygonPath = Path();
      for (var j = 0; j < data.first.points.length; j++) {
        final x = center.dx + radius * i / options.maxValue * math.cos(j * angle - math.pi / 2);
        final y = center.dy + radius * i / options.maxValue * math.sin(j * angle - math.pi / 2);
        if (j == 0) {
          polygonPath.moveTo(x, y);
        } else {
          polygonPath.lineTo(x, y);
        }
      }
      polygonPath.close();
      canvas.drawPath(polygonPath, gridPaint);
    }

    // draw data
    for (var item in data) {
      final dataPath = Path();
      final dataPaint = Paint()
        ..color = item.fillColor
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = item.borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = item.lineWidth;
      for (var i = 0; i < item.points.length; i++) {
        final x = center.dx +
            radius * item.points[i].value / options.maxValue * math.cos(i * angle - math.pi / 2);
        final y = center.dy +
            radius * item.points[i].value / options.maxValue * math.sin(i * angle - math.pi / 2);
        if (i == 0) {
          dataPath.moveTo(x, y);
        } else {
          dataPath.lineTo(x, y);
        }
      }
      dataPath.close();
      canvas.drawPath(dataPath, dataPaint);
      canvas.drawPath(dataPath, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}