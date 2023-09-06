import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:tomo_split/tomo_split.dart';

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
  final ValueNotifier<CutImage?> _selectedImage = ValueNotifier(null);
  final ValueNotifier<int> _selectedIndex = ValueNotifier(-1);

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
    mqttClientManager.subscribe(_room);

    await mqttClientManager.setArrived((c) async {
      final recMess = c[0].payload as MqttPublishMessage;
      final jsonStr = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _selectedWidgets.value = splitManager.coverJson(jsonStr);
      _selectedImage.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split Receiver Example')),
      body: Center(
        child: Column(
          children: [
            ValueListenableBuilder<List<Widget>>(
              valueListenable: _selectedWidgets,
              builder: (_, widgets, __) => SizedBox(
                  height: MediaQuery.of(context).size.height / 2,
                  child: AspectRatio(aspectRatio: ratio, child: Stack(children: widgets))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ValueListenableBuilder<int>(
                    valueListenable: _selectedIndex,
                    builder: (_, i, ___) {
                      if (i == -1) {
                        return const Text('Transition failed');
                      } else if (i == -2) {
                        return const Text('Loading..');
                      } else {
                        return Text('index : $i');
                      }
                    }),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedWidgets.value.isEmpty) return;
                    _selectedIndex.value = -2;
                    final index = Random().nextInt(_selectedWidgets.value.length);

                    final img = await splitManager.getCutImage(index);
                    if (img == null) {
                      _selectedIndex.value = -1;
                      return;
                    }
                    _selectedIndex.value = index;
                    _selectedImage.value = img;
                  },
                  child: const Text('Capture Random Index'),
                ),
              ],
            ),
            Expanded(
                child: ColoredBox(
                    color: Colors.black12,
                    child: ValueListenableBuilder<CutImage?>(
                      valueListenable: _selectedImage,
                      builder: (_, ci, ___) => ci == null
                          ? const SizedBox()
                          : GestureDetector(
                              onTap: () {
                                final size = splitManager.getWidgetSize(ci.index);
                                if (size == null) return;

                                final positionSize = ci.getPositionSize(size);

                                final List<Widget> buf = List.from(_selectedWidgets.value);
                                buf[ci.index] = Positioned(
                                  left: positionSize.x,
                                  top: positionSize.y,
                                  child: Image.memory(
                                    ci.uint8Image,
                                    width: positionSize.width,
                                    height: positionSize.height,
                                  ),
                                );

                                _selectedWidgets.value = buf;
                              },
                              child: Image.memory(ci.uint8Image),
                            ),
                    )))
          ],
        ),
      ),
    );
  }
}
