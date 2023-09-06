import 'package:flutter/material.dart';

import 'clip_info.dart';
import 'mode_clipper.dart';
import 'mode_painter.dart';

class ClipperWidget extends StatelessWidget {
  ClipperWidget({
    super.key,
    required this.child,
    required this.converter,
    required this.args,
    required this.strokeColor,
    required this.showOutLine,
  });

  final Widget child;
  final ClipConverter converter;
  final Map<String, dynamic> args;
  final Color strokeColor;
  final bool showOutLine;

  final GlobalKey boundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
            key: boundaryKey,
            child: ClipPath(
              clipper: ModeClipper(sizePathConverter: converter, args: args),
              child: child,
            )),
        if (showOutLine)
          CustomPaint(
            painter: ModePainter(
              sizePathConverter: converter,
              args: args,
              strokeColor: strokeColor,
            ),
          ),
      ],
    );
  }
}
