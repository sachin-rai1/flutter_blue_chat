import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'chat_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            // Start scanning
            flutterBlue.startScan(timeout: const Duration(seconds: 4));
            flutterBlue.scanResults.listen((results) {
              for (ScanResult result in results) {
                print("Hii");
                if (devices.contains(result.device)) {
                  setState(() {
                    devices.add(result.device);
                  });
                }
              }
            });
            flutterBlue.stopScan();

          }, child: const Text("Scan")),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return (devices.isEmpty)?const Center(child: Text("No Device Found"),) : ListTile(
                  title: Text(devices[index].name),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(device: devices[index]),
                    ),
                  ),
                );
              },
              itemCount: devices.length,
            ),
          ),
        ],
      ),
    );
  }
}
