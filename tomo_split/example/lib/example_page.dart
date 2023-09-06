import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tomo_split/tomo_split.dart';

class ExamplePage extends StatelessWidget {
  ExamplePage({Key? key, required this.uint8Image}) : super(key: key) {
    manager = SplitManager(Image.memory(uint8Image, fit: BoxFit.fill));
  }

  final Uint8List uint8Image;

  final ValueNotifier<List<Widget>> _selectedWidgets = ValueNotifier([]);
  late final SplitManager manager;

  final ValueNotifier<int> xNum = ValueNotifier(4);
  final ValueNotifier<int> yNum = ValueNotifier(4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Example')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
            child: Image.memory(uint8Image, fit: BoxFit.fill),
          ),
          numSliders,
          buttons,
          Expanded(
            /// 스택으로 한번에 볼때
            child: ValueListenableBuilder<List<Widget>>(
              valueListenable: _selectedWidgets,
              builder: (_, widgets, __) => Stack(fit: StackFit.expand, children: widgets),
            ),

            /// 세로 리스트로 볼때
            // child: ValueListenableBuilder<List<Widget>>(
            //   valueListenable: _selectedWidgets,
            //   builder: (_, widgets, __) => SingleChildScrollView(
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.stretch,
            //       children: widgets
            //           .map(
            //               (e) => SizedBox(height: MediaQuery.of(context).size.height / 4, child: e))
            //           .toList(),
            //     ),
            //   ),
            // ),
          ),
        ],
      ),
    );
  }

  Widget get buttons => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              _selectedWidgets.value = manager.coverRectangle(xNum.value, yNum.value);
              print('sHong] 1:: ${manager.jsonStr}');
            },
            child: const Text('직선 분할'),
          ),
          ElevatedButton(
            onPressed: () {
              _selectedWidgets.value = manager.coverDiagonal(xNum.value, yNum.value, strokeColor: Colors.red);
              print('sHong] 2:: ${manager.jsonStr}');
            },
            child: const Text('사선 분할'),
          ),
          ElevatedButton(
            onPressed: () {
              _selectedWidgets.value = manager.coverJigsaw(xNum.value, yNum.value, strokeColor: Colors.cyan);
              print('sHong] 3:: ${manager.jsonStr}');
            },
            child: const Text('직쏘 퍼즐 분할'),
          ),
        ],
      );

  get numSliders => Column(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: xNum,
            builder: (_, x, __) {
              return Row(
                children: [
                  Text('가로 : $x'),
                  Expanded(
                    child: Slider(
                      value: x.toDouble(),
                      min: 2,
                      max: 10,
                      onChanged: (val) {
                        xNum.value = val.toInt();
                      },
                      divisions: 8,
                      label: '$x',
                    ),
                  ),
                ],
              );
            },
          ),
          ValueListenableBuilder<int>(
            valueListenable: yNum,
            builder: (_, y, __) {
              return Row(
                children: [
                  Text('세로 : $y'),
                  Expanded(
                    child: Slider(
                      value: y.toDouble(),
                      min: 2,
                      max: 10,
                      onChanged: (val) {
                        yNum.value = val.toInt();
                      },
                      divisions: 8,
                      label: '$y',
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );
}
