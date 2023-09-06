import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:tomo_split/clip/mode_clipper.dart';

import 'clip/clipper_widget.dart';
import 'tomo_split.dart';
import 'transducer/diagonal_transducer.dart';
import 'transducer/jigsaw_transducer.dart';
import 'transducer/rectangle_transducer.dart';

enum SplitMode {
  rectangle,
  diagonal,
  jigsaw,
  undefined,
}

class SplitManager {
  SplitManager(this.baseWidget);

  final Widget baseWidget;
  BaseTransducer? _currentTransducer;

  static const limitRatio = 1.2;

  static Future<List<Uint8List>> runImageSplit(Uint8List uint8Image, int xNum, int yNum) async {
    img.Image image = img.decodeImage(uint8Image)!;

    final int width = (image.width / xNum).floor();
    final int height = (image.height / yNum).floor();
    int x = 0, y = 0;

    final List<img.Image> parts = [];
    for (int i = 0; i < yNum; i++) {
      for (int j = 0; j < xNum; j++) {
        parts.add(img.copyCrop(image, x: x, y: y, width: width, height: height));
        x += width;
      }
      x = 0;
      y += height;
    }

    final List<Uint8List> output = [];
    for (var part in parts) {
      output.add(img.encodePng(part));
    }

    return output;
  }

  static Future<IntSize> imageSizeAsync(Uint8List uint8Image) async {
    final cmd = img.Command()..decodeImage(uint8Image);
    await cmd.executeThread();
    img.Image? image = cmd.outputImage;
    if (image == null) {
      throw Exception('Image decode failed!');
    }
    final width = image.width;
    final height = image.height;
    return IntSize(width, height);
  }

  static IntSize imageSize(Uint8List uint8Image) {
    img.Image? image = img.decodeImage(uint8Image);
    if (image == null) {
      throw Exception('Image decode failed!');
    }
    final width = image.width;
    final height = image.height;
    return IntSize(width, height);
  }

  static List<IntSize> imageRecommendSizeWithSize(
      int imgWidth, int imgHeight, int standard, SplitMode mode) {
    final width = imgWidth;
    final height = imgHeight;

    int x1 = 1;
    int y1 = 1;
    int x2 = 1;
    int y2 = 1;
    int cnt = 1;
    if (width > height) {
      final value = width / height;
      while (true) {
        x1 = (value * cnt).round();
        y1 = cnt;
        if (splitNum(mode, x1, y1) >= standard) {
          x1 = math.min((value * (cnt)).floor(), (value * (cnt)).ceil());
          y1 = cnt;
          x2 = (value * (cnt + 1)).round();
          y2 = cnt + 1;
          break;
        }
        cnt++;
      }
    } else {
      final value = height / width;
      while (true) {
        x1 = cnt;
        y1 = (value * cnt).round();
        if (splitNum(mode, x1, y1) >= standard) {
          x1 = cnt;
          y1 = math.min((value * (cnt)).floor(), (value * (cnt)).ceil());
          x2 = cnt + 1;
          y2 = (value * (cnt + 1)).round();
          break;
        }
        cnt++;
      }
    }

    final rcList = <IntSize>[];
    for (int x = math.min(x1, x2); x <= math.max(x1, x2); x++) {
      for (int y = math.min(y1, y2); y <= math.max(y1, y2); y++) {
        final ratio = (width / x) / (height / y);
        final lr = math.max(limitRatio, 1 / limitRatio);
        if (ratio > lr || ratio < 1 / lr) {
          continue;
        } else if (splitNum(mode, x, y) < standard) {
          continue;
        } else {
          rcList.add(IntSize(x, y));
        }
      }
    }

    if (rcList.isEmpty) {
      if (width > height) {
        final value = width / height;
        x1 = (value * cnt).round();
        y1 = cnt;
        x2 = (value * (cnt + 1)).round();
        y2 = cnt + 1;
      } else {
        final value = height / width;
        x1 = cnt;
        y1 = (value * cnt).round();
        x2 = cnt + 1;
        y2 = (value * (cnt + 1)).round();
      }
      rcList.add(IntSize(x1, y1));
      rcList.add(IntSize(x2, y2));
    }
    rcList.sort(
        (a, b) => splitNum(mode, a.xValue, a.yValue).compareTo(splitNum(mode, b.xValue, b.yValue)));

    return rcList;
  }

  static List<IntSize>? imageRecommendSize(Uint8List uint8Image, int standard, SplitMode mode) {
    final size = imageSize(uint8Image);
    return imageRecommendSizeWithSize(size.xValue, size.yValue, standard, mode);
  }

  static int splitNum(SplitMode mode, int x, int y) {
    switch (mode) {
      case SplitMode.rectangle:
        return x * y;
      case SplitMode.diagonal:
        return 2 * x * y + x + y;
      case SplitMode.jigsaw:
        return x * y;
      default:
        throw Exception('<SplitManager> 정의되지 않은 splitMode');
    }
  }

  List<ClipperWidget> coverRectangle(int xNum, int yNum,
      {Color strokeColor = Colors.lightGreenAccent, bool showOutLine = true, List<dynamic>? json}) {
    _currentTransducer = RectangleTransducer(
      xNum: xNum,
      yNum: yNum,
      child: baseWidget,
      strokeColor: strokeColor,
      showOutLine: showOutLine,
      json: json,
    );
    return _currentTransducer!.widgets;
  }

  List<ClipperWidget> coverDiagonal(int xNum, int yNum,
      {Color strokeColor = Colors.lightGreenAccent, bool showOutLine = true, List<dynamic>? json}) {
    _currentTransducer = DiagonalTransducer(
      xNum: xNum,
      yNum: yNum,
      child: baseWidget,
      strokeColor: strokeColor,
      showOutLine: showOutLine,
      json: json,
    );
    return _currentTransducer!.widgets;
  }

  List<ClipperWidget> coverJigsaw(int xNum, int yNum,
      {Color strokeColor = Colors.lightGreenAccent, bool showOutLine = true, List<dynamic>? json}) {
    _currentTransducer = JigsawTransducer(
      xNum: xNum,
      yNum: yNum,
      child: baseWidget,
      strokeColor: strokeColor,
      showOutLine: showOutLine,
      json: json,
    );
    return _currentTransducer!.widgets;
  }

  List<ClipperWidget> coverJson(String jsonStr,
      {Color strokeColor = Colors.lightGreenAccent, bool showOutLine = true}) {
    final jsonBuf = json.decode(jsonStr) as Map<String, dynamic>;
    final modeStr = jsonBuf['mode'];
    final xNum = int.parse(jsonBuf['xNum']);
    final yNum = int.parse(jsonBuf['yNum']);
    final listJson = jsonBuf['args'];
    final mode = _parseMode(modeStr);
    switch (mode) {
      case SplitMode.rectangle:
        return coverRectangle(xNum, yNum, strokeColor: strokeColor, showOutLine: showOutLine, json: listJson);
      case SplitMode.diagonal:
        return coverDiagonal(xNum, yNum, strokeColor: strokeColor, showOutLine: showOutLine, json: listJson);
      case SplitMode.jigsaw:
        return coverJigsaw(xNum, yNum, strokeColor: strokeColor, showOutLine: showOutLine, json: listJson);
      default:
        return [];
    }
  }

  List<ModeClipper> get clippers =>
      _currentTransducer?.clipInfoList
          .map((e) => ModeClipper(sizePathConverter: e.sizePathConverter, args: e.args))
          .toList() ??
      [];

  String get jsonStr => ({
        '"mode"': '"${_currentTransducer?.mode.name}"',
        '"xNum"': '"${_currentTransducer?.xNum}"',
        '"yNum"': '"${_currentTransducer?.yNum}"',
        '"args"': _currentTransducer?.argsList ?? [],
      }).toString();

  static SplitMode _parseMode(String modeStr) {
    for (final event in SplitMode.values) {
      if (event.name == modeStr) {
        return event;
      }
    }
    print('<DrawEvent> undefined Type! Can not parse');
    return SplitMode.undefined;
  }

  Future<CutImage?> getCutImage(int index) async {
    final image = await getCaptureToImages(index);
    if (image == null) return null;
    img.Image? uiImage = img.decodeImage(image);
    if (uiImage == null) {
      return null;
    }
    final baseImgSize = IntSize(uiImage.width, uiImage.height);
    final cutSize = getCutSize(baseImgSize, index);
    if (cutSize == null) return null;
    final cutImage = SplitManager.cutSizeCropWithImage(uiImage, cutSize);
    return CutImage(index, cutImage, cutSize, baseImgSize);
  }

  Future<CutImage?> getCutImageAsync(int index) async {
    final image = await getCaptureToImages(index);
    if (image == null) return null;
    final uiImageCmd = img.Command()..decodeImage(image);
    await uiImageCmd.executeThread();
    img.Image? uiImage = uiImageCmd.outputImage;
    if (uiImage == null) {
      return null;
    }
    final baseImgSize = IntSize(uiImage.width, uiImage.height);
    final cutSize = getCutSize(baseImgSize, index);
    if (cutSize == null) return null;
    final cutImage = await cutSizeCropWithImageAsync(uiImage, cutSize);
    if (cutImage == null) return null;
    return CutImage(index, cutImage, cutSize, baseImgSize);
  }

  Future<Uint8List?> getCaptureToImages(int index) async =>
      await _currentTransducer?.getImage(index);

  CutSize? getCutSize(IntSize size, int index) => _currentTransducer?.getCutSize(size, index);

  PositionSize? getPositionSize(IntSize size, int index) =>
      _currentTransducer?.getPositionSize(size, index);

  Future<Uint8List?> cutSizeCropWithImageAsync(img.Image image, CutSize c) async {
    final cmd = img.Command()
      ..image(image)
      ..copyCrop(x: c.x, y: c.y, width: c.width, height: c.height)
      ..encodePng();
    await cmd.executeThread();
    return cmd.outputBytes;
  }

  static Future<Uint8List> cutSizeCropAsync(Uint8List uint8Image, CutSize c) async {
    final cmd = img.Command()
      ..decodeImage(uint8Image)
      ..copyCrop(x: c.x, y: c.y, width: c.width, height: c.height)
      ..encodePng();
    await cmd.executeThread();
    return cmd.outputBytes!;
  }

  static Uint8List cutSizeCropWithImage(img.Image src, CutSize c) {
    final dst = img.copyCrop(src, x: c.x, y: c.y, width: c.width, height: c.height);

    return img.encodePng(dst);
  }

  static Uint8List cutSizeCrop(Uint8List uint8Image, CutSize c) {
    img.Image src = img.decodeImage(uint8Image)!;
    final dst = img.copyCrop(src, x: c.x, y: c.y, width: c.width, height: c.height);

    return img.encodePng(dst);
  }

  List<ClipperWidget>? get widgets => _currentTransducer?.widgets;

  Size? getWidgetSize(int index) =>
      _currentTransducer?.widgets[index].boundaryKey.currentContext?.size;

  static Future<Uint8List> getUIImageWithAsset(
    String assetPath, {
    int? svgWidth,
    int? svgHeight,
  }) async {
    final typeStr = assetPath.substring(assetPath.length - 3, assetPath.length);

    switch (typeStr) {
      case 'svg':
        final pictureInfo = await vg.loadPicture(SvgAssetLoader(assetPath), null);
        final bufImage = await pictureInfo.picture.toImage(
          svgWidth ?? pictureInfo.size.width.toInt(),
          svgHeight ?? pictureInfo.size.height.toInt(),
        );
        final uint8List =
            (await bufImage.toByteData(format: ui.ImageByteFormat.png))?.buffer.asUint8List();
        if (uint8List == null) throw Exception('can not convert SVG file to Uint8List');
        bufImage.dispose();
        return uint8List;
      default:
        final ByteData assetImageByteData = await rootBundle.load(assetPath);
        return assetImageByteData.buffer.asUint8List();
    }
  }
}
