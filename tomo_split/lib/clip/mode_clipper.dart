import 'package:flutter/material.dart';

import 'clip_info.dart';

class ModeClipper extends CustomClipper<Path> {
  ModeClipper({required this.sizePathConverter, required this.args});

  final ClipConverter sizePathConverter;
  final Map<String, dynamic> args;

  @override
  Path getClip(Size size) {
    return sizePathConverter.call(size, args);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
