import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';

class MQTTService {
  static final MQTTService _instance =
      MQTTService._internal(); // Singleton instance
  factory MQTTService() => _instance; // Factory constructor
  MQTTService._internal(); // Private constructor

  late MqttServerClient client; // MQTT client instance
  Function(Map<String, dynamic>)?
  onMessageReceived; // Callback for incoming messages

  bool _isConnecting = false; // Prevent multiple connection attempts

  Future<void> connect() async {
    client = MqttServerClient.withPort(
      '7d838d4406204b7798758a6bc4117f48.s1.eu.hivemq.cloud',
      // HiveMQ broker URL
      'flutter_client_${DateTime.now().millisecondsSinceEpoch}', // Unique client ID
      8883, // Secure MQTT port
    );

    // Avoid reconnecting if already connected or in process
    if (client.connectionStatus?.state == MqttConnectionState.connected ||
        _isConnecting) {
      print("🔌 Already connected to HiveMQ Cloud ✅");
      return;
    }

    _isConnecting = true;
    try {
      client.secure = true; // Enable secure connection
      client.securityContext =
          SecurityContext.defaultContext; // Default SSL context
      client.keepAlivePeriod = 20; // Keep-alive interval
      client.logging(on: false); // Disable verbose logging

      client.onDisconnected = onDisconnected; // Callback when disconnected
      client.onConnected = onConnected; // Callback when connected

      print("🔄 Connecting to HiveMQ...");
      await client.connect("Ahmed", "Am1992005"); // Authenticate with broker

      // Check connection status
      if (client.connectionStatus?.state == MqttConnectionState.connected) {
        print("✅ Connected to HiveMQ Cloud!");
        _subscribeToDefaultTopics(); // Subscribe to default topics
      } else {
        print("❌ Connection failed. Status: ${client.connectionStatus}");
        client.disconnect();
      }
    } catch (e) {
      print("❌ Exception: $e");
      client.disconnect();
    }

    _isConnecting = false;
  }

  void _subscribeToDefaultTopics() {
    final topics = [
      'home/entrydoor',
      'home/exitdoor',
      'home/led',
      'home/buzzer',
    ];

    // Subscribe to each topic
    for (var topic in topics) {
      client.subscribe(topic, MqttQos.atLeastOnce);
      print("📡 Subscribed to $topic");
    }

    // Listen for incoming messages
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> event) {
      final recMess = event[0].payload as MqttPublishMessage;
      final message = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );
      final topic = event[0].topic;

      print("Received: '$message' on '$topic'");
      if (onMessageReceived != null) {
        onMessageReceived!({
          "topic": topic,
          "message": message,
        }); // Trigger callback
      }
    });
  }

  void publishMessage(String topic, String message) {
    // Check connection before publishing
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message); // Add message payload
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print("Published '$message' to '$topic'");
    } else {
      print("Cannot publish - MQTT disconnected");
    }
  }

  void onConnected() =>
      print("Connected to HiveMQ Cloud"); // Connected callback
  void onDisconnected() =>
      print("Disconnected from HiveMQ Cloud"); // Disconnected callback

  bool get isConnected =>
      client.connectionStatus?.state ==
      MqttConnectionState.connected; // Check connection
}
