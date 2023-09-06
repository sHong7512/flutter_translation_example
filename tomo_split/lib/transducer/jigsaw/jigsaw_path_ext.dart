import 'dart:math';

import 'package:flutter/material.dart';

import 'jigsaw_info.dart';

extension JigsawPathExt on Path {
  xJigsawTo(JigsawInfo j) {
    if (j.maxSize.height > j.start.dy + j.radius && 0 < j.start.dy - j.radius) {
      final dif = (j.end.dx - j.start.dx) / 2;
      if (dif > 0) {
        final s = j.pattern ? -pi : pi;
        final standard = j.start.dx + (j.end.dx - j.start.dx) / 2;
        lineTo(standard - j.radius + j.lineWidthCor, j.start.dy);
        arcTo(
            Rect.fromCircle(center: Offset(standard, j.start.dy), radius: j.radius), pi, s, false);
      } else {
        final s = j.pattern ? pi : -pi;
        final standard = j.end.dx - (j.end.dx - j.start.dx) / 2;
        lineTo(standard + j.radius - j.lineWidthCor, j.start.dy);
        arcTo(Rect.fromCircle(center: Offset(standard, j.start.dy), radius: j.radius), 0, s, false);
      }
    }
    lineTo(j.end.dx, j.end.dy);
  }

  yJigsawTo(JigsawInfo j) {
    if (j.maxSize.width > j.start.dx + j.radius && 0 < j.start.dx - j.radius) {
      final dif = (j.end.dy - j.start.dy) / 2;
      if (dif > 0) {
        final s = j.pattern ? -pi : pi;
        final standard = j.start.dy + (j.end.dy - j.start.dy) / 2;
        lineTo(j.start.dx, standard - j.radius + j.lineWidthCor);
        arcTo(Rect.fromCircle(center: Offset(j.start.dx, standard), radius: j.radius), 3 * pi / 2,
            s, false);
        lineTo(j.end.dx, j.end.dy);
      } else {
        final s = j.pattern ? pi : -pi;
        final standard = j.end.dy - (j.end.dy - j.start.dy) / 2;
        lineTo(j.start.dx, standard + j.radius - j.lineWidthCor);
        arcTo(Rect.fromCircle(center: Offset(j.start.dx, standard), radius: j.radius), pi / 2, s,
            false);
      }
    }
    lineTo(j.end.dx, j.end.dy);
  }
}
