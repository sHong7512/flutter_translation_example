import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'fade_anim_widget.dart';

class FadeTransWidget extends StatefulWidget {
  const FadeTransWidget({
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
  State<FadeTransWidget> createState() => _FadeTransWidgetState();
}

class _FadeTransWidgetState extends State<FadeTransWidget> {
  final ValueNotifier<List<Widget>> _curWidgets = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    initialize();
  }

  initialize() async {
    final List<Widget> allWidgets = [];
    for (final uint in widget.uint8Images) {
      allWidgets.add(Image.memory(uint, fit: BoxFit.fill));
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
    return ValueListenableBuilder<List<Widget>>(
      valueListenable: _curWidgets,
      builder: (_, cw, __) {
        if (cw.isEmpty) return const Center(child: Text('로딩중..'));
        return SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? double.infinity,
          child: Stack(
            children: [
              FadeAnimWidget(
                duration: Duration(milliseconds: widget.animMillis),
                isForward: false,
                child: cw[0],
              ),
              FadeAnimWidget(
                duration: Duration(milliseconds: widget.animMillis),
                isForward: true,
                child: cw[1],
              ),
            ],
          ),
        );
      },
    );
  }
}
