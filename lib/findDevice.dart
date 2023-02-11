import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_chat/chat_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class FindDevice extends StatefulWidget {
  const FindDevice({Key? key}) : super(key: key);

  @override
  State<FindDevice> createState() => _FindDeviceState();
}

class _FindDeviceState extends State<FindDevice> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];

  Future<void> checkAndRequestBluetoothPermission() async {
    PermissionStatus permission = await Permission.bluetoothScan.status;

    if (permission != PermissionStatus.granted) {
      Map<Permission, PermissionStatus> permissions = await [
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise
      ].request();

      if (permissions[Permission.bluetoothScan] != PermissionStatus.granted) {
        Get.snackbar("Allow bluetooth permission", "permission not allowed");
      }
    }
    if (permission == PermissionStatus.granted) {
      flutterBlue.startScan(timeout: const Duration(seconds: 4));
      flutterBlue.scanResults.listen((results) {
        for (ScanResult result in results) {
          if (!devices.contains(result.device) &&
              result.device.name != "" &&
              result.device.state.toString() !=
                  "BluetoothDeviceState.disconnected") {
            setState(() {
              // print(result.device);
              // print("Device state ${result.device.state.toString()}");
              // print("Device name is : ${result.device.name}");
              // print("Device visibility is : ${result.device.isDiscoveringServices}");
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
      appBar: AppBar(
        title: const Text('Find Devices'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            flutterBlue.startScan(timeout: const Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<List<BluetoothDevice>>(
                  stream: Stream.periodic(const Duration(seconds: 2)).asyncMap((_) => flutterBlue.connectedDevices),
                  builder: (c, snapshot) {
                    return (snapshot.data == null)
                        ? const Center(child: Text("No device found"))
                        : Column(
                            children: snapshot.data!.map((d) => ListTile(
                                      title: Text(d.name),
                                      subtitle: Text(d.id.toString()),
                                      trailing:
                                          StreamBuilder<BluetoothDeviceState>(
                                        stream: d.state,
                                        initialData:
                                            BluetoothDeviceState.disconnected,
                                        builder: (c, snapshot) {
                                          if (snapshot.data ==
                                              BluetoothDeviceState.connected) {
                                            return ElevatedButton(
                                              child: const Text('OPEN'),
                                              onPressed: () =>
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatScreen(
                                                                  device: d))),
                                            );
                                          }
                                          return Text(snapshot.data.toString());
                                        },
                                      ),
                                    ))
                                .toList(),
                          );
                  }),
              StreamBuilder<List<ScanResult>>(
                stream: flutterBlue.scanResults,
                builder: (c, snapshot) {
                  print("Hey ");
                  return (snapshot.data == null)
                      ? const Text("Hello")
                      : Column(
                      children: snapshot.data!
                          .map((r) => Text(r.device.name)).toList());
                }
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: flutterBlue.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () => flutterBlue.stopScan(),
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () =>
                    flutterBlue.startScan(timeout: const Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
