import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:polar_explorer/heart_rate_service.dart';

import 'device_selector.dart';
import 'device_selector_view_model.dart';

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
            return Text("Bluetooth off, please turn on Bluetooth to continue");
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color.fromRGBO(24, 26, 66, 1.0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(24, 26, 66, 1.0),
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(title: 'Flutter Demo Home Page'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _bluetoothState = false;
  UserBluetoothDevice? selectedDeviceId;
  BluetoothConnectionState? _connectionState;
  Timer? _scanTimer;
  List<BluetoothService> _services = [];
  BluetoothService? _bluetoothService;
  BluetoothCharacteristic? _bluetoothCharacteristic;
  BluetoothService? _heartRateData;
  late DeviceSelectorViewModel _deviceSelectorViewModel;

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

  Future _getServices(BluetoothDevice device) async {
    try {
      _services = await device.discoverServices();
      _bluetoothService = _services.first;
      _bluetoothCharacteristic = _bluetoothService!.characteristics.first;
      _heartRateData = _services.firstWhere(
        (service) => service.uuid.toString().toLowerCase().contains("180d"),
      );
      _deviceSelectorViewModel.updateDeviceState(
        connectionState: _connectionState,
        services: _services,
      );
    } catch (e) {
      // TODO: Handle the exception properly, e.g., show a dialog to the user or log the error.
      print(e.toString());
    }
  }

  Future _connectionStateStream(BluetoothDevice device) async {
    try {
      await device
          .connect(license: License.free)
          .then((value) {
            device.connectionState.listen((event) async {
              setState(() {
                if (event == BluetoothConnectionState.connected) {
                  _connectionState = BluetoothConnectionState.connected;
                } else if (event == BluetoothConnectionState.disconnected) {
                  _connectionState = BluetoothConnectionState.disconnected;
                } else {
                  _connectionState = null;
                }
              });
              _deviceSelectorViewModel.updateDeviceState(
                connectionState: _connectionState,
                services: _services,
              );
            });
          })
          .catchError((e) {
            // TODO: Handle the exception properly, e.g., show a dialog to the user or log the error.
            print(e.toString());
          });
    } catch (e) {
      // TODO: Handle the exception properly, e.g., show a dialog to the user or log the error.
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _deviceSelectorViewModel = DeviceSelectorViewModel();
    _deviceSelectorViewModel.init();
    getPermissions().then((_) {
      _startScan();
      _scanTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _startScan();
        if (selectedDeviceId != null && selectedDeviceId!.device != null) {
          _connectionStateStream(selectedDeviceId!.device!);
          _getServices(selectedDeviceId!.device!);
        }
      });
    });
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _deviceSelectorViewModel.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            BluetoothAdapterStatus(onStateChanged: _updateBluetoothState),
            DeviceSelector(
              viewModel: _deviceSelectorViewModel,
              onDeviceSelected: (device) => setState(() {
                selectedDeviceId = device;
              }),
            ),
            HeartRateService(
              heartRateService: _heartRateData,
              connectionState: _connectionState,
            ),
          ],
        ),
      ),
    );
  }
}
