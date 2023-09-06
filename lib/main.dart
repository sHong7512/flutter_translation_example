import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tomo_split/split_manager.dart';
import 'package:translation_example/fade/fade_trans_widget.dart';
import 'package:translation_example/glass_cube/glass_cube_trans_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final List<String> pathList = [
    'assets/test_play.jpg',
    'assets/test_play2.jpg',
    'assets/pattern1.png',
    'assets/pattern2.jpg',
    'assets/svgTest.svg'
  ];

  final List<Uint8List> uint8Images = [];
  for (final path in pathList) {
    uint8Images.add(await SplitManager.getUIImageWithAsset(path));
  }

  runApp(MaterialApp(home: ExamplePage(uint8Images: uint8Images)));
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({Key? key, required this.uint8Images}) : super(key: key);

  final List<Uint8List> uint8Images;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Expanded(
          //   child: FadeTransWidget(
          //     uint8Images: uint8Images,
          //     animMillis: 2000,
          //     changeMillis: 3000,
          //   ),
          // ),
          Expanded(
            child: GlassCubeTransWidget(
              uint8Images: uint8Images,
              animMillis: 3000,
              changeMillis: 3000,
            ),
          ),
        ],
      ),
    );
  }
}
