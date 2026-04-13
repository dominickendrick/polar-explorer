import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

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
  int _counter = 0;
  bool _bluetoothState = false;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermissions();
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
            Text("Bluetooth State: ${_bluetoothState.toString()}"),
            StreamBuilder(
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
                    _updateBluetoothState(isOn);
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
            ),
            StreamBuilder<bool>(
              stream: FlutterBluePlus.isScanning,
              initialData: false,
              builder: (c, snapshot) {
                if (snapshot.data!) {
                  return FloatingActionButton(
                    child: const Icon(Icons.stop, color: Colors.red),
                    onPressed: () => FlutterBluePlus.stopScan(),
                    backgroundColor: Color(0xFFEDEDED),
                  );
                } else {
                  return FloatingActionButton(
                    child: Icon(Icons.search, color: Colors.blue.shade300),
                    backgroundColor: Color(0xFFEDEDED),
                    onPressed: () => FlutterBluePlus.startScan(
                      timeout: const Duration(seconds: 4),
                    ),
                  );
                }
              },
            ),
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.scanResults,
              initialData: const [],
              builder: (c, snapshot) {
                List<ScanResult> scanresults = snapshot.data!;
                List<ScanResult> templist = [];
                scanresults.forEach((element) {
                  if (element.device.platformName != "") {
                    templist.add(element);
                  }
                });
                return Column(
                  children: templist.map((r) {
                    if (r.device.platformName.contains("Polar")) {
                      return ListTile(
                        title: Text(r.device.platformName),
                        subtitle: Text(r.device.remoteId.toString()),
                        trailing: Text(r.rssi.toString()),
                      );
                    } else {
                      return Container();
                    }
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
