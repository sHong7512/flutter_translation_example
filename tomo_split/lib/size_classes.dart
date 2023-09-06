import 'dart:typed_data';

import 'package:flutter/material.dart';

class IntSize {
  IntSize(this.xValue, this.yValue);

  int xValue;
  int yValue;

  Size get toDoubleSize => Size(xValue.toDouble(), yValue.toDouble());
}

class PositionSize {
  PositionSize(this.x, this.y, this.width, this.height);

  final double x;
  final double y;
  final double width;
  final double height;
}

class CutSize {
  CutSize(this.x, this.y, this.width, this.height);

  final int x;
  final int y;
  final int width;
  final int height;
}

class CutImage {
  CutImage(this.index, this.uint8Image, this.cutSize, this.baseImgSize);

  final int index;
  final Uint8List uint8Image;
  final CutSize cutSize;
  final IntSize baseImgSize;

  PositionSize getPositionSize(Size parentSize) {
    final x = cutSize.x * parentSize.width / baseImgSize.xValue;
    final y = cutSize.y * parentSize.height / baseImgSize.yValue;
    final width = cutSize.width * parentSize.width / baseImgSize.xValue;
    final height = cutSize.height * parentSize.height / baseImgSize.yValue;
    return PositionSize(x, y, width, height);
  }

  static PositionSize transPositionSize(Size parentSize, CutSize cutSize, IntSize baseImgSize) {
    final x = cutSize.x * parentSize.width / baseImgSize.xValue;
    final y = cutSize.y * parentSize.height / baseImgSize.yValue;
    final width = cutSize.width * parentSize.width / baseImgSize.xValue;
    final height = cutSize.height * parentSize.height / baseImgSize.yValue;
    return PositionSize(x, y, width, height);
  }
}
