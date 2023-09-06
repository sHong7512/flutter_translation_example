import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tomo_split/tomo_split.dart';

import 'glass_cube_anim_widget.dart';

class GlassCubeTransWidget extends StatefulWidget {
  const GlassCubeTransWidget({
    Key? key,
    required this.uint8Images,
    required this.animMillis,
    required this.changeMillis,
    this.width,
    this.height,
  }) : super(key: key);

  final List<Uint8List> uint8Images;
  final int animMillis;
  final int changeMillis;
  final double? width;
  final double? height;

  @override
  State<GlassCubeTransWidget> createState() => _GlassCubeTransWidgetState();
}

class _GlassCubeTransWidgetState extends State<GlassCubeTransWidget> {
  final ValueNotifier<List<List<Widget>>> _curWidgets = ValueNotifier([]);
  final delta = 1.5;
  final widthDivision = 10;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    final List<List<Widget>> allWidgets = [];
    for (final uint in widget.uint8Images) {
      final sm = SplitManager(Image.memory(uint, fit: BoxFit.fill));
      sm.coverRectangle(widthDivision, 2, showOutLine: false);
      final widgets = sm.widgets;
      if (widgets != null) {
        allWidgets.add(widgets);
      }
    }

    for (int i = 0; i < 1000; i++) {
      _curWidgets.value = [
        allWidgets[i % allWidgets.length],
        allWidgets[(i + 1) % allWidgets.length]
      ];
      await Future.delayed(Duration(milliseconds: widget.changeMillis));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ValueListenableBuilder<List<List<Widget>>>(
            valueListenable: _curWidgets,
            builder: (ctx, cw, _) {
              if (cw.isEmpty) return const Center(child: Text('로딩중..'));

              final topList = cw[1].getRange(0, cw[1].length ~/ 2).toList();
              final bottomList = cw[1].getRange(cw[1].length ~/ 2, cw[1].length).toList();

              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return SizedBox(
                width: widget.width ?? double.infinity,
                height: widget.height ?? double.infinity,
                child: Stack(children: [
                  ...cw[0],
                  ...topList
                      .asMap()
                      .entries
                      .map((e) => GlassCubeAnimWidget(
                    millis: widget.animMillis * delta * delta ~/ bottomList.length,
                    startDelayMillis: widget.animMillis * e.key ~/ bottomList.length ~/ delta,
                            parentSize: size,
                            index: e.key,
                            division: widthDivision,
                            isTopBottom: true,
                            child: e.value,
                          ))
                      .toList(),
                  ...bottomList
                      .asMap()
                      .entries
                      .map((e) => GlassCubeAnimWidget(
                            millis: widget.animMillis * delta * delta ~/ bottomList.length,
                            startDelayMillis: widget.animMillis * e.key ~/ bottomList.length ~/ delta,
                            parentSize: size,
                            index: e.key,
                            division: widthDivision,
                            isTopBottom: false,
                            child: e.value,
                          ))
                      .toList(),
                ]),
              );
            },
          );
        },
      ),
    );
  }
}