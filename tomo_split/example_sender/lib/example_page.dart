import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:tomo_split/split_manager.dart';

import 'mqtt_client_manager.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key, required this.uint8Image}) : super(key: key);

  final Uint8List uint8Image;

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  static const _room = "$TOP_TOPIC/splitRoom";
  final MQTTClientManager mqttClientManager = MQTTClientManager(primaryId: '${DateTime.now()}');

  late final SplitManager splitManager;
  late final double ratio;
  final ValueNotifier<List<Widget>> _selectedWidgets = ValueNotifier([]);
  final ValueNotifier<int> xNum = ValueNotifier(3);
  final ValueNotifier<int> yNum = ValueNotifier(3);
  final ValueNotifier<int> people = ValueNotifier(20);

  @override
  void initState() {
    setupMqttClient();
    splitManager = SplitManager(Image.memory(widget.uint8Image, fit: BoxFit.fill));
    final size = SplitManager.imageSize(widget.uint8Image);
    ratio = size.xValue / size.yValue;
    super.initState();
  }

  Future<void> setupMqttClient() async {
    await mqttClientManager.connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Sender Example')),
      body: exampleRecommendList,
    );
  }

  Widget get example => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.memory(widget.uint8Image, fit: BoxFit.contain),
          numSliders,
          buttons,
          recommendSlider,
          recommendButtons,
          ValueListenableBuilder<List<Widget>>(
              valueListenable: _selectedWidgets,
              builder: (_, widgets, __) =>
                  AspectRatio(aspectRatio: ratio, child: Stack(children: widgets))),
          ValueListenableBuilder<List<Widget>>(
              valueListenable: _selectedWidgets,
              builder: (_, widgets, __) => Text('잘린 갯수 : ${widgets.length}')),
        ],
      );

  final ValueNotifier<List<List<Widget>>> _recoTestWidgets = ValueNotifier([]);
  final ValueNotifier<List<String>> _recoTestStrings = ValueNotifier([]);

  Widget get exampleRecommendList => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          recommendSlider,
          ElevatedButton(
            onPressed: () {
              final recommendSize = SplitManager.imageRecommendSize(
                widget.uint8Image,
                people.value,
                SplitMode.rectangle,
              );
              if (recommendSize != null) {
                final list = <List<Widget>>[];
                final list2 = <String>[];
                for (final r in recommendSize) {
                  list.add(splitManager.coverRectangle(r.xValue, r.yValue));
                  list2.add('${r.xValue} : ${r.yValue} = ${r.xValue * r.yValue}');
                }
                _recoTestWidgets.value = list;
                _recoTestStrings.value = list2;
              }
            },
            child: const Text('추천 비율 전부 보기'),
          ),
          ValueListenableBuilder<List<List<Widget>>>(
              valueListenable: _recoTestWidgets,
              builder: (_, widgets, __) => Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                          children: widgets
                              .asMap()
                              .entries
                              .map((e) => Column(
                                    children: [
                                      AspectRatio(
                                          aspectRatio: ratio, child: Stack(children: e.value)),
                                      Text(_recoTestStrings.value[e.key]),
                                    ],
                                  ))
                              .toList()),
                    ),
                  )),
        ],
      );

  Widget get recommendSlider => ValueListenableBuilder<int>(
        valueListenable: people,
        builder: (_, p, __) {
          return Row(
            children: [
              Text('추천 기준 인원수 : $p'),
              Expanded(
                child: Slider(
                  value: p.toDouble(),
                  min: 1,
                  max: 100,
                  onChanged: (val) {
                    people.value = val.toInt();
                  },
                  divisions: 100,
                  label: '$p',
                ),
              ),
            ],
          );
        },
      );

  Widget get recommendButtons => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              final recommendSize = SplitManager.imageRecommendSize(
                widget.uint8Image,
                people.value,
                SplitMode.rectangle,
              );
              if (recommendSize != null) {
                xNum.value = recommendSize[0].xValue;
                yNum.value = recommendSize[0].yValue;
              }
            },
            child: const Text('직선 추천'),
          ),
          ElevatedButton(
            onPressed: () {
              final recommendSize = SplitManager.imageRecommendSize(
                widget.uint8Image,
                people.value,
                SplitMode.diagonal,
              );
              if (recommendSize != null) {
                xNum.value = recommendSize[0].xValue;
                yNum.value = recommendSize[0].yValue;
              }
            },
            child: const Text('사선 추천'),
          ),
          ElevatedButton(
            onPressed: () {
              final recommendSize = SplitManager.imageRecommendSize(
                widget.uint8Image,
                people.value,
                SplitMode.jigsaw,
              );
              if (recommendSize != null) {
                xNum.value = recommendSize[0].xValue;
                yNum.value = recommendSize[0].yValue;
              }
            },
            child: const Text('직쏘 퍼즐 추천'),
          ),
        ],
      );

  Widget get buttons => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              _selectedWidgets.value = splitManager.coverRectangle(xNum.value, yNum.value);
              mqttClientManager.publishMessage(_room, splitManager.jsonStr);
            },
            child: const Text('직선 분할'),
          ),
          ElevatedButton(
            onPressed: () {
              _selectedWidgets.value =
                  splitManager.coverDiagonal(xNum.value, yNum.value, strokeColor: Colors.red);
              mqttClientManager.publishMessage(_room, splitManager.jsonStr);
            },
            child: const Text('사선 분할'),
          ),
          ElevatedButton(
            onPressed: () {
              _selectedWidgets.value =
                  splitManager.coverJigsaw(xNum.value, yNum.value, strokeColor: Colors.cyan);
              mqttClientManager.publishMessage(_room, splitManager.jsonStr);
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
                      min: 1,
                      max: 50,
                      onChanged: (val) {
                        xNum.value = val.toInt();
                      },
                      divisions: 50,
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
                      min: 1,
                      max: 50,
                      onChanged: (val) {
                        yNum.value = val.toInt();
                      },
                      divisions: 50,
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
