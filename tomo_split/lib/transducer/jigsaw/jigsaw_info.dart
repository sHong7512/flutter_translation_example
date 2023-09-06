import 'package:flutter/material.dart';

import '../../clip/mode_painter.dart';

class JigsawInfo {
  JigsawInfo({
    required this.start,
    required this.end,
    required this.radius,
    required this.pattern,
    required this.maxSize,
  });

  final Offset start;
  final Offset end;
  final Size maxSize;
  final double radius;
  final bool pattern;

  final double lineWidthCor = ModePainter.painterLineWidth / 2;
}
