import 'package:flutter/material.dart';

class FadeAnimWidget extends StatefulWidget {
  const FadeAnimWidget({
    Key? key,
    required this.duration,
    required this.child,
    required this.isForward,
  }) : super(key: key);

  final Duration duration;
  final Widget child;
  final bool isForward;

  @override
  State<FadeAnimWidget> createState() => _FadeAnimWidgetState();
}

class _FadeAnimWidgetState extends State<FadeAnimWidget> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> animation;

  _start() {
    if (widget.isForward) {
      controller.reset();
      controller.value = 0;
      controller.forward();
    } else {
      controller.value = 1;
      controller.reverse();
    }
  }

  _setAnimation() {
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: widget.duration, vsync: this);
    _setAnimation();
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _start();
    return FadeTransition(
      opacity: animation,
      child: SizedBox(width: double.infinity, height: double.infinity, child: widget.child),
    );
  }
}
