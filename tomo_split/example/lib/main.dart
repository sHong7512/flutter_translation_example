import 'package:example/example_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ByteData assetImageByteData = await rootBundle.load('assets/test_play.jpg');
  final uint8Image = assetImageByteData.buffer.asUint8List();

  runApp(MaterialApp(home: ExamplePage(uint8Image: uint8Image)));
}
