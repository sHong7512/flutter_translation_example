import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:typed_data/typed_buffers.dart';

/**
 * MQTT v3, v3.1.1
 */
const String SERVER_IP = '192.168.2.133';
// const String SERVER_IP = '10.254.120.85';
const int SERVER_PORT = 1883;
const String TOP_TOPIC = 'topic';

class MQTTClientManager {
  MQTTClientManager({required this.primaryId}) {
    client = MqttServerClient.withPort(SERVER_IP, primaryId, SERVER_PORT);
  }

  final String primaryId;

  late MqttServerClient client;

  StreamSubscription? _arrivedStream;
  StreamSubscription? _publishedStream;

  Future<int> connect() async {
    client.logging(on: true);
    client.keepAlivePeriod = 65535;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    client.autoReconnect = true;

    final connMessage = MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('MQTTClient::Client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('MQTTClient::Socket exception - $e');
      client.disconnect();
    }

    return 0;
  }

  void disconnect() {
    client.disconnect();
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  Future<void> setArrived(Function(List<MqttReceivedMessage<MqttMessage>>) onArrived) async {
    await _arrivedStream?.cancel();
    _arrivedStream = client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      // final recMess = c![0].payload as MqttPublishMessage;
      // final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('shong] Change<Sub> notification:: list Size = ${c.length}');
      onArrived.call(c);
    });
  }

  Future<void> setPublished() async {
    await _publishedStream?.cancel();
    _publishedStream = client.published!.listen((MqttPublishMessage message) {
      print(
          'shong] Published notification:: topic = ${message.variableHeader!.topicName}, Qos = ${message.header!.qos}');
    });
  }

  void onConnected() {
    print('MQTTClient::Connected');
  }

  void onDisconnected() {
    print('MQTTClient::Disconnected');
  }

  void onSubscribed(String topic) {
    print('MQTTClient::Subscribed to topic: $topic');
  }

  void pong() {
    print('MQTTClient::Ping response received');
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  void publishUnit8List(String topic, Uint8List unit8List) {
    Uint8Buffer dataBuffer = Uint8Buffer();
    dataBuffer.addAll(unit8List);
    client.publishMessage(topic, MqttQos.exactlyOnce, dataBuffer);
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client.updates;
  }
}
