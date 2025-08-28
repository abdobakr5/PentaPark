import 'package:flutter/material.dart';
import '../helpers/MQTT.dart';
import '../Widgets/build_control_item.dart';

class ControlPanelMQTT extends StatefulWidget {
  const ControlPanelMQTT({super.key});

  @override
  State<ControlPanelMQTT> createState() => _ControlPanelMQTTState();
}

class _ControlPanelMQTTState extends State<ControlPanelMQTT> {
  final mqttService = MQTTService(); // Create MQTT service instance

  bool entryDoorOpen = false; // Track entry door state
  bool exitDoorOpen = false; // Track exit door state
  bool ledOn = false; // Track LED state
  bool buzzerOn = false; // Track buzzer state

  @override
  void initState() {
    super.initState();

    // Listen for incoming MQTT messages
    mqttService.onMessageReceived = (data) {
      final topic = data["topic"];
      final message = data["message"];

      // Update UI when message is received
      setState(() {
        switch (topic) {
          case "home/entrydoor":
            entryDoorOpen = message == "open";
            break;
          case "home/exitdoor":
            exitDoorOpen = message == "open";
            break;
          case "home/led":
            ledOn = message == "on";
            break;
          case "home/buzzer":
            buzzerOn = message == "on";
            break;
        }
      });
    };
  }

  // Toggle device state and send MQTT message
  void _toggleDevice({
    required String topic,
    required bool currentState,
    required String onMessage,
    required String offMessage,
  }) {
    final message = currentState ? offMessage : onMessage;
    mqttService.publishMessage(topic, message); // Publish to MQTT broker
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Control Panel"), // App bar title
      ),
      body: ListView(
        children: [
          // Entry Door control
          buildControlItem(
            label: "Entry Door",
            isOn: entryDoorOpen,
            onToggle: () => _toggleDevice(
              topic: "home/entrydoor",
              currentState: entryDoorOpen,
              onMessage: "open",
              offMessage: "close",
            ),
          ),
          // Exit Door control
          buildControlItem(
            label: "Exit Door",
            isOn: exitDoorOpen,
            onToggle: () => _toggleDevice(
              topic: "home/exitdoor",
              currentState: exitDoorOpen,
              onMessage: "open",
              offMessage: "close",
            ),
          ),
          // LED control
          buildControlItem(
            label: "LED",
            isOn: ledOn,
            onToggle: () => _toggleDevice(
              topic: "home/led",
              currentState: ledOn,
              onMessage: "on",
              offMessage: "off",
            ),
          ),
          // Buzzer control
          buildControlItem(
            label: "Buzzer",
            isOn: buzzerOn,
            onToggle: () => _toggleDevice(
              topic: "home/buzzer",
              currentState: buzzerOn,
              onMessage: "on",
              offMessage: "off",
            ),
          ),
        ],
      ),
    );
  }
}
