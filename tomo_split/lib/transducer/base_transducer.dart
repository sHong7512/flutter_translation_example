import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../clip/clip_info.dart';
import '../clip/clipper_widget.dart';
import '../tomo_split.dart';

abstract class BaseTransducer {
  BaseTransducer({
    required this.child,
    required this.xNum,
    required this.yNum,
    required Color strokeColor,
    required bool showOutLine,
    required this.mode,
    List<dynamic>? json,
  }) {
    clipInfoList = json == null ? setClipInfo() : fromJsonClipInfo(json);
    widgets = clipInfoList
        .map((e) => ClipperWidget(
              converter: e.sizePathConverter,
              args: e.args,
              strokeColor: strokeColor,
              showOutLine: showOutLine,
              child: child,
            ))
        .toList();
  }

  final Widget child;
  late final List<ClipperWidget> widgets;
  late final List<ClipInfo> clipInfoList;
  final SplitMode mode;

  final int xNum;
  final int yNum;

  List<ClipInfo> setClipInfo();

  List<ClipInfo> fromJsonClipInfo(List<dynamic> jsonList);

  CutSize? getCutSize(IntSize size, int i) {
    final positionSize = getPositionSize(size, i);
    if (positionSize == null) {
      return null;
    }
    return CutSize(positionSize.x.floor(), positionSize.y.floor(),
        positionSize.width.ceil(), positionSize.height.ceil());
  }

  PositionSize? getPositionSize(IntSize size, int i);

  Future<Uint8List?> getImage(int i) async =>
      await _capture(widgets[i].boundaryKey, 0);

  List<Map<String, dynamic>> get argsList => clipInfoList.map((e) {
        final convArgs = <String, dynamic>{};
        for (final k in e.args.keys) {
          convArgs['"$k"'] = '"${e.args[k]}"';
        }
        return convArgs;
      }).toList();

  final _maxCaptureCnt = 100;
  Future<Uint8List?> _capture(GlobalKey boundaryKey, int cnt,
      [bool improve = true]) async {
    try {
      if (cnt == _maxCaptureCnt) return null;

      await Future.delayed(const Duration(milliseconds: 20));
      final context = boundaryKey.currentContext;
      final boundary = context?.findRenderObject() as RenderRepaintBoundary?;
      final isNeedsPaint = kDebugMode ? boundary?.debugNeedsPaint : false;

      if (boundary == null ||
          isNeedsPaint != false ||
          context == null ||
          !context.mounted) {
        print("<BaseTransducer> <$hashCode> Waiting for boundary & context ..");
        await Future.delayed(const Duration(milliseconds: 20));
        return _capture(boundaryKey, cnt + 1, improve);
      }

      final width = boundary.size.width;
      final height = boundary.size.height;

      double widthRatio = MediaQuery.of(context).size.width / width;
      double heightRatio = MediaQuery.of(context).size.height / height;
      if (improve) {
        widthRatio =
            ui.PlatformDispatcher.instance.views.first.physicalSize.width /
                width;
        heightRatio =
            ui.PlatformDispatcher.instance.views.first.physicalSize.height /
                height;
      }
      final pixelRatio = widthRatio < heightRatio ? widthRatio : heightRatio;

      await Future.delayed(const Duration(milliseconds: 20));
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData != null) {
        return Uint8List.view(byteData.buffer);
      } else {
        throw Exception('byteData is null!');
      }
    } catch (e) {
      print('<BaseTransducer> <$hashCode> $e');
      return null;
    }
  }
}
