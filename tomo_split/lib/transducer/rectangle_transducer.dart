import 'package:flutter/material.dart';

import '../clip/clip_info.dart';
import '../tomo_split.dart';

class RectangleTransducer extends BaseTransducer {
  RectangleTransducer({
    required Widget child,
    required super.xNum,
    required super.yNum,
    required Color strokeColor,
    required bool showOutLine,
    List<dynamic>? json,
  }) : super(
          child: child,
          strokeColor: strokeColor,
          showOutLine: showOutLine,
          mode: SplitMode.rectangle,
          json: json,
        );

  @override
  List<ClipInfo> setClipInfo() {
    final bufList = <ClipInfo>[];
    for (int i = 0; i < yNum; i++) {
      for (int j = 0; j < xNum; j++) {
        bufList.add(
          ClipInfo(
            sizePathConverter: rectangleConverter,
            args: {'index': j, 'moveCnt': i},
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
      bufList.add(
        ClipInfo(
          sizePathConverter: rectangleConverter,
          args: {'index': index, 'moveCnt': moveCnt},
        ),
      );
    }
    return bufList;
  }

  Path rectangleConverter(Size size, Map<String, dynamic> args) {
    final index = args['index'] as int;
    final moveCnt = args['moveCnt'] as int;
    final double moveX = size.width / xNum;
    final double moveY = size.height / yNum;
    final double baseX = index * size.width / xNum;
    final double baseY = moveCnt * size.height / yNum;

    Path path = Path();
    path.moveTo(baseX, baseY);
    path.lineTo(baseX + moveX, baseY);
    path.lineTo(baseX + moveX, baseY + moveY);
    path.lineTo(baseX, baseY + moveY);
    path.lineTo(baseX, baseY);

    path.close();
    return path;
  }

  @override
  PositionSize? getPositionSize(IntSize size, int i) {
    if (i >= clipInfoList.length) return null;

    final info = clipInfoList[i];
    final index = info.args['index'] as int;
    final moveCnt = info.args['moveCnt'] as int;

    final double moveX = size.xValue / xNum;
    final double moveY = size.yValue / yNum;
    final baseX = index * size.xValue / xNum;
    final baseY = moveCnt * size.yValue / yNum;

    return PositionSize(baseX, baseY, moveX, moveY);
  }
}
