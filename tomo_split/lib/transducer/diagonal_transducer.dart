import 'dart:math';

import 'package:flutter/material.dart';

import '../clip/clip_info.dart';
import '../tomo_split.dart';

class DiagonalTransducer extends BaseTransducer {
  DiagonalTransducer({
    required super.xNum,
    required super.yNum,
    required Widget child,
    required Color strokeColor,
    required bool showOutLine,
    List<dynamic>? json,
  }) : super(
          child: child,
          strokeColor: strokeColor,
          showOutLine: showOutLine,
          mode: SplitMode.diagonal,
          json: json,
        );

  @override
  List<ClipInfo> setClipInfo() {
    final bufList = <ClipInfo>[];
    // X stand
    for (int i = 0; i < yNum; i++) {
      for (int j = 0; j <= xNum; j++) {
        bufList.add(
          ClipInfo(
            sizePathConverter: standConverter,
            args: {'index': j, 'moveCnt': i, 'isXStand': true},
          ),
        );
      }
    }
    // Y stand
    for (int i = 0; i < xNum; i++) {
      for (int j = 0; j <= yNum; j++) {
        bufList.add(
          ClipInfo(
            sizePathConverter: standConverter,
            args: {'index': j, 'moveCnt': i, 'isXStand': false},
          ),
        );
      }
    }
    return bufList;
  }

  @override
  List<ClipInfo> fromJsonClipInfo(List<dynamic> jsonList) {
    final bufList = <ClipInfo>[];
    for (var js in jsonList) {
      final index = int.parse(js['index']);
      final moveCnt = int.parse(js['moveCnt']);
      final isXStand = bool.parse(js['isXStand']);
      bufList.add(
        ClipInfo(
          sizePathConverter: standConverter,
          args: {'index': index, 'moveCnt': moveCnt, 'isXStand': isXStand},
        ),
      );
    }

    return bufList;
  }

  Path standConverter(Size size, Map<String, dynamic> args) {
    final index = args['index'] as int;
    final moveCnt = args['moveCnt'] as int;
    final isXStand = args['isXStand'] as bool;
    final double moveX = size.width / (xNum * 2);
    final double moveY = size.height / (yNum * 2);
    final double baseX = isXStand
        ? index * size.width / xNum
        : moveCnt * size.width / xNum + moveX;
    final double baseY = isXStand
        ? moveCnt * size.height / yNum + moveY
        : index * size.height / yNum;

    final path = Path();
    path.moveTo(baseX, max(0, baseY - moveY));
    path.lineTo(min(size.width, baseX + moveX), baseY);
    path.lineTo(baseX, min(size.height, baseY + moveY));
    path.lineTo(max(0, baseX - moveX), baseY);
    path.lineTo(baseX, max(0, baseY - moveY));
    path.close();
    return path;
  }

  @override
  PositionSize? getPositionSize(IntSize size, int i) {
    if (i >= clipInfoList.length) return null;
    final info = clipInfoList[i];

    final index = info.args['index'] as int;
    final moveCnt = info.args['moveCnt'] as int;
    final isXStand = info.args['isXStand'] as bool;
    final double moveX = size.xValue / (xNum * 2);
    final double moveY = size.yValue / (yNum * 2);
    final double baseX = isXStand
        ? index * size.xValue / xNum
        : moveCnt * size.xValue / xNum + moveX;
    final double baseY = isXStand
        ? moveCnt * size.yValue / yNum + moveY
        : index * size.yValue / yNum;

    final x = max(0.0, baseX - moveX);
    final y = max(0.0, baseY - moveY);
    final width = min(size.xValue, baseX + moveX) - x;
    final height = min(size.yValue, baseY + moveY) - y;

    return PositionSize(x, y, width, height);
  }
}
