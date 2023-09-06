import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tomo_split/transducer/jigsaw/jigsaw_path_ext.dart';

import '../clip/clip_info.dart';
import '../tomo_split.dart';
import 'jigsaw/jigsaw_info.dart';
import 'jigsaw/jigsaw_line.dart';

class JigsawTransducer extends BaseTransducer {
  JigsawTransducer({
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
          mode: SplitMode.jigsaw,
          json: json,
        );

  @override
  List<ClipInfo> setClipInfo() {
    final bufList = <ClipInfo>[];
    final xLineMap = <int, Map<int, Map<int, JigsawLine>>>{};
    for (int i = 0; i <= yNum; i++) {
      xLineMap[i] = {};
      for (int j = 0; j < xNum; j++) {
        xLineMap[i]![j] = {};
      }
    }

    for (int i = 0; i < yNum; i++) {
      final yLineMap = <int, JigsawLine>{
        0: JigsawLine(radius: 0, pattern: true),
      };
      for (int j = 0; j < xNum; j++) {
        if (i == 0) {
          xLineMap[i]![j]![0] =
              JigsawLine(radius: randRadius, pattern: Random().nextBool());
          xLineMap[i]![j]![1] =
              JigsawLine(radius: randRadius, pattern: Random().nextBool());
          xLineMap[i + 1]![j]![0] = xLineMap[i]![j]![1]!;
        } else {
          xLineMap[i]![j]![1] =
              JigsawLine(radius: randRadius, pattern: Random().nextBool());
          xLineMap[i + 1]![j]![0] = xLineMap[i]![j]![1]!;
        }

        if (!yLineMap.containsKey(j + 1)) {
          yLineMap[j + 1] =
              JigsawLine(radius: randRadius, pattern: Random().nextBool());
        }

        bufList.add(
          ClipInfo(
            sizePathConverter: jigsawConverter,
            args: {
              'index': j,
              'moveCnt': i,
              'radiusList': [
                xLineMap[i]![j]![0]!.radius,
                yLineMap[j + 1]!.radius,
                xLineMap[i]![j]![1]!.radius,
                yLineMap[j]!.radius,
              ],
              'patternList': [
                xLineMap[i]![j]![0]!.pattern,
                yLineMap[j + 1]!.pattern,
                xLineMap[i]![j]![1]!.pattern,
                yLineMap[j]!.pattern,
              ],
            },
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
      final radiusList = <double>[];
      final patternList = <bool>[];
      final radiusJS = json.decode(js['radiusList']);
      for (final radiusStr in radiusJS) {
        radiusList.add(double.parse(radiusStr.toString()));
      }

      final patternJS = json.decode(js['patternList']);
      for (final patternStr in patternJS) {
        patternList.add(bool.parse(patternStr.toString()));
      }
      bufList.add(
        ClipInfo(
          sizePathConverter: jigsawConverter,
          args: {
            'index': index,
            'moveCnt': moveCnt,
            'radiusList': radiusList,
            'patternList': patternList,
          },
        ),
      );
    }

    return bufList;
  }

  double get randRadius {
    int min = 6;
    int max = 10;
    return (min + Random().nextInt(max - min)).toDouble();
  }

  Path jigsawConverter(Size size, Map<String, dynamic> args) {
    final index = args['index'] as int;
    final moveCnt = args['moveCnt'] as int;
    final radiusList = args['radiusList'] as List<double>;
    final patternList = args['patternList'] as List<bool>;
    final double moveX = size.width / xNum;
    final double moveY = size.height / yNum;
    final double baseX = index * size.width / xNum;
    final double baseY = moveCnt * size.height / yNum;

    Path path = Path();
    path.moveTo(baseX, baseY);

    path.xJigsawTo(JigsawInfo(
      start: Offset(baseX, baseY),
      end: Offset(baseX + moveX, baseY),
      maxSize: size,
      radius: min(moveY * 0.4, radiusList[0] * moveX * 0.025),
      pattern: patternList[0],
    ));

    path.yJigsawTo(JigsawInfo(
      start: Offset(baseX + moveX, baseY),
      end: Offset(baseX + moveX, baseY + moveY),
      maxSize: size,
      radius: min(moveX * 0.4, radiusList[1] * moveY * 0.025),
      pattern: patternList[1],
    ));

    path.xJigsawTo(JigsawInfo(
      start: Offset(baseX + moveX, baseY + moveY),
      end: Offset(baseX, baseY + moveY),
      maxSize: size,
      radius: min(moveY * 0.4, radiusList[2] * moveX * 0.025),
      pattern: patternList[2],
    ));

    path.yJigsawTo(JigsawInfo(
      start: Offset(baseX, baseY + moveY),
      end: Offset(baseX, baseY),
      maxSize: size,
      radius: min(moveX * 0.4, radiusList[3] * moveY * 0.025),
      pattern: patternList[3],
    ));

    path.close();
    return path;
  }

  @override
  PositionSize? getPositionSize(IntSize size, int i) {
    if (i >= clipInfoList.length) return null;

    final e = clipInfoList[i];
    final index = e.args['index'] as int;
    final moveCnt = e.args['moveCnt'] as int;
    final radiusList = e.args['radiusList'] as List<double>;
    final patternList = e.args['patternList'] as List<bool>;
    final double moveX = size.xValue / xNum;
    final double moveY = size.yValue / yNum;
    final double baseX = index * size.xValue / xNum;
    final double baseY = moveCnt * size.yValue / yNum;

    final xr = min(moveY * 0.4, radiusList[0] * moveX * 0.025);
    final xb = testX(JigsawInfo(
      start: Offset(baseX, baseY),
      end: Offset(baseX + moveX, baseY),
      maxSize: size.toDoubleSize,
      radius: xr,
      pattern: patternList[0],
    ));

    final yr = min(moveX * 0.4, radiusList[1] * moveY * 0.025);
    final yb = testY(JigsawInfo(
      start: Offset(baseX + moveX, baseY),
      end: Offset(baseX + moveX, baseY + moveY),
      maxSize: size.toDoubleSize,
      radius: yr,
      pattern: patternList[1],
    ));

    final xr2 = min(moveY * 0.4, radiusList[2] * moveX * 0.025);
    final xb2 = testX(JigsawInfo(
      start: Offset(baseX + moveX, baseY + moveY),
      end: Offset(baseX, baseY + moveY),
      maxSize: size.toDoubleSize,
      radius: xr2,
      pattern: patternList[2],
    ));

    final yr2 = min(moveX * 0.4, radiusList[3] * moveY * 0.025);
    final yb2 = testY(JigsawInfo(
      start: Offset(baseX, baseY + moveY),
      end: Offset(baseX, baseY),
      maxSize: size.toDoubleSize,
      radius: yr2,
      pattern: patternList[3],
    ));

    final x = yb2 ? baseX - yr2 : baseX;
    final y = xb ? baseY - xr : baseY;
    final x2 = yb ? baseX + moveX + yr : baseX + moveX;
    final y2 = xb2 ? baseY + moveY + xr2 : baseY + moveY;
    final width = x2 - x;
    final height = y2 - y;

    return PositionSize(x, y, width, height);
  }

  bool testX(JigsawInfo j) {
    if (j.maxSize.height > j.start.dy + j.radius && 0 < j.start.dy - j.radius) {
      final dif = (j.end.dx - j.start.dx) / 2;
      double s;
      if (dif > 0) {
        s = j.pattern ? -pi : pi;
      } else {
        s = j.pattern ? pi : -pi;
      }
      return s >= 0;
    }
    return false;
  }

  bool testY(JigsawInfo j) {
    final dif = (j.end.dy - j.start.dy) / 2;
    if (j.maxSize.width > j.start.dx + j.radius && 0 < j.start.dx - j.radius) {
      double s;
      if (dif > 0) {
        s = j.pattern ? -pi : pi;
      } else {
        s = j.pattern ? pi : -pi;
      }
      return s >= 0;
    }
    return false;
  }
}
