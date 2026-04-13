import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class UserBluetoothDevice {
  final String deviceId;
  final String deviceName;

  UserBluetoothDevice({required this.deviceId, required this.deviceName});
}

class BluetoothAdapterStatus extends StatelessWidget {
  const BluetoothAdapterStatus({super.key, required this.onStateChanged});

  final void Function(bool isOn) onStateChanged;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterBluePlus.adapterState.handleError((e) {
        // TODO: Handle the error properly, e.g., show a dialog to the user or log the error.
        print(e.toString());
      }),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Bluetooth unavailable");
        }
        if (snapshot.hasData) {
          final isOn = snapshot.data == BluetoothAdapterState.on;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onStateChanged(isOn);
          });
          if (isOn) {
            return Text("Bluetooth on");
          } else {
            return Text(
              "Bluetooth off, please turn on Bluetooth to continue",
            );
          }
        } else {
          return Container();
        }
      },
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polar Explorer',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _bluetoothState = false;
  UserBluetoothDevice? selectedDeviceId;
  Timer? _scanTimer;

  void _updateBluetoothState(bool isOn) {
    setState(() {
      _bluetoothState = isOn;
    });
  }

  Future getPermissions() async {
    try {
      await Permission.bluetooth.request();
    } catch (e) {
      // TODO: Handle the exception properly, e.g., show a dialog to the user or log the error.
      print(e.toString());
    }
  }

  Future _startScan() async {
    if (!(await FlutterBluePlus.isScanning.first)) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    }
  }

  @override
  void initState() {
    super.initState();
    getPermissions().then((_) {
      _startScan();
      _scanTimer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => _startScan(),
      );
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            BluetoothAdapterStatus(onStateChanged: _updateBluetoothState),
            if (selectedDeviceId != null)
              Column(
                children: [
                  Text("Selected Device:"),
                  Text(selectedDeviceId!.deviceName),
                  Text(selectedDeviceId!.deviceId),
                ],
              )
            else
              StreamBuilder<List<ScanResult>>(
                stream: FlutterBluePlus.scanResults,
                initialData: const [],
                builder: (c, snapshot) {
                  List<ScanResult> scanresults = snapshot.data!;
                  List<ScanResult> templist = [];
                  scanresults.forEach((element) {
                    if (element.device.platformName.contains("Polar")) {
                      templist.add(element);
                    }
                  });
                  return Column(
                    children: templist.map((r) {
                      return ListTile(
                        title: Text(r.device.platformName),
                        subtitle: Text(r.device.remoteId.toString()),
                        trailing: Text(r.rssi.toString()),
                        onTap: () => setState(() {
                          selectedDeviceId = UserBluetoothDevice(
                            deviceId: r.device.remoteId.toString(),
                            deviceName: r.device.platformName,
                          );
                        }),
                      );
                    }).toList(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
