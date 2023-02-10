import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ChatScreen extends StatefulWidget {
  final BluetoothDevice device;

  ChatScreen({required this.device});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late BluetoothDevice device;
  late BluetoothCharacteristic characteristic;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    device = widget.device;
    connect();
  }

  Future<void> connect() async {
    device.connect();
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      List<BluetoothCharacteristic> characteristics = service.characteristics;
      for (var characteristic in characteristics) {
        if (characteristic.uuid.toString() == 'your_chat_service_uuid') {
          this.characteristic = characteristic;
        }
      }
    }
  }

  Future<void> sendMessage(String message) async {
    List<int> bytes = utf8.encode(message);
    await characteristic.write(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: const <Widget>[
                  // Add your chat messages here
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Enter your message',
              ),
            ),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                String message = textController.text;
                if (message.isNotEmpty) {
                  sendMessage(message);
                  textController.clear();
                }
              },
              child: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}



