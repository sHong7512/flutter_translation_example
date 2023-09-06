import 'package:flutter/material.dart';
import 'package:tomo_split/split_manager.dart';

import 'example_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final uint8Image = await SplitManager.getUIImageWithAsset('assets/test_play.jpg');
  // final uint8Image = await SplitManager.getUIImageWithAsset('assets/test_play2.jpg');
  // final uint8Image = await SplitManager.getUIImageWithAsset('assets/pattern1.png');
  final uint8Image = await SplitManager.getUIImageWithAsset('assets/pattern2.jpg');
  // final uint8Image = await SplitManager.getUIImageWithAsset('assets/svgTest.svg');

  runApp(MaterialApp(home: ExamplePage(uint8Image: uint8Image)));
}
