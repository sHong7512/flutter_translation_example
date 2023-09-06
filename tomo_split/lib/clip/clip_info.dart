import 'package:flutter/material.dart';

typedef ClipConverter = Path Function(Size size, Map<String, dynamic> args);

class ClipInfo {
  ClipInfo({required this.sizePathConverter, required this.args});

  final ClipConverter sizePathConverter;
  final Map<String, dynamic> args;
}
