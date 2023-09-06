import 'package:flutter/material.dart';

class GlassCubeAnimWidget extends StatefulWidget {
  const GlassCubeAnimWidget({
    Key? key,
    required this.millis,
    required this.startDelayMillis,
    required this.parentSize,
    required this.isTopBottom,
    required this.index,
    required this.division,
    required this.child,
  }) : super(key: key);

  final int millis;
  final int startDelayMillis;
  final Size parentSize;
  final bool isTopBottom;
  final int index;
  final int division;
  final Widget child;

  @override
  State<GlassCubeAnimWidget> createState() => _GlassCubeAnimWidgetState();
}

class _GlassCubeAnimWidgetState extends State<GlassCubeAnimWidget> with TickerProviderStateMixin {
  late final AnimationController controller;
  late final AnimationController controller2;
  Animation<RelativeRect>? animation;
  Animation<RelativeRect>? animation2;
  final isComplete = ValueNotifier<bool>(false);

  _start() async {
    isComplete.value = false;
    controller.reset();
    await Future.delayed(Duration(milliseconds: widget.startDelayMillis ~/ 2));
    controller.value = 0;
    controller.forward();
  }

  _setAnimation(Size s) {
    final value =
        (widget.parentSize.width / widget.division) * (1 - widget.index / widget.division);

    if (widget.isTopBottom) {
      animation = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, -s.height, -value, s.height),
        end: RelativeRect.fromLTRB(0, 0, -value, 0),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.ease));
    } else {
      animation = RelativeRectTween(
        begin: RelativeRect.fromLTRB(0, s.height, -value, -s.height),
        end: RelativeRect.fromLTRB(0, 0, -value, 0),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.ease));
    }

    animation!.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        animation2 = RelativeRectTween(
          begin: RelativeRect.fromLTRB(
            0,
            0,
            -value,
            0,
          ),
          end: const RelativeRect.fromLTRB(0, 0, 0, 0),
        ).animate(CurvedAnimation(parent: controller2, curve: Curves.ease));
        isComplete.value = true;
        controller2.reset();
        controller2.value = 0;
        controller2.forward();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: widget.millis * 3 ~/ 2), vsync: this);
    controller2 =
        AnimationController(duration: Duration(milliseconds: widget.millis ~/ 2), vsync: this);
  }

  @override
  dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _setAnimation(widget.parentSize);
    _start();

    return ValueListenableBuilder<bool>(
      valueListenable: isComplete,
      builder: (_, ic, __) {
        return PositionedTransition(
          rect: ic ? animation2! : animation!,
          child: SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.child,
          ),
        );
      },
    );
  }
}
