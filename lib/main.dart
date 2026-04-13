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
          ],
        ),
      ),
    );
  }
}
