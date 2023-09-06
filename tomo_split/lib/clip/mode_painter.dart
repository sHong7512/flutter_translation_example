import 'package:flutter/material.dart';

import 'clip_info.dart';

class ModePainter extends CustomPainter {
  ModePainter({required this.sizePathConverter, required this.args, required this.strokeColor});

  static const painterLineWidth = 3.0;

  final ClipConverter sizePathConverter;
  final Map<String, dynamic> args;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = sizePathConverter(size, args);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor
      ..strokeWidth = painterLineWidth;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
