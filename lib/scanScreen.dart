import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'chat_screen.dart';
import 'package:get/get.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  Future<void> checkAndRequestBluetoothPermission() async {
    PermissionStatus permission = await Permission.bluetoothScan.status;

    if (permission != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> permissions = await [Permission.bluetooth, Permission.bluetoothScan , Permission.bluetoothConnect,Permission.bluetoothAdvertise].request();

      if (permissions[Permission.bluetoothScan] != PermissionStatus.granted) {
        Get.snackbar("Allow bluetooth permission", "permission not allowed");
      }
    }
    if(permission == PermissionStatus.granted){
      flutterBlue.startScan(timeout: const Duration(seconds: 4));
      flutterBlue.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!devices.contains(result.device) && result.device.name != "" && result.device.state.toString() != "BluetoothDeviceState.disconnected") {
            setState(() {
              print(result.device);
              print("Device state ${result.device.state.toString()}");
              print("Device name is : ${result.device.name}");
              print("Device visibility is : ${result.device.isDiscoveringServices}");
              devices.add(result.device);
            });
          }
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkAndRequestBluetoothPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Bluetooth') , centerTitle: true,),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          print("Device Length = ${devices.length}");
          return (devices.isEmpty)?const Center(child: Text("No Device Found"),) : ListTile(
            title: Text((devices[index].name == "") ? "Unknown Device" : devices[index].name),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatScreen(device: devices[index]),
              ),
            ),
          );
        },

      ),
    );
  }
}