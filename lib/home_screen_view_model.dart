import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'device_selector.dart';
import 'device_selector_view_model.dart';

class HomeScreenViewModel extends ChangeNotifier {
  bool _bluetoothState = false;
  UserBluetoothDevice? _selectedDeviceId;
  BluetoothConnectionState? _connectionState;
  Timer? _scanTimer;
  List<BluetoothService> _services = [];
  BluetoothService? _bluetoothService;
  BluetoothCharacteristic? _bluetoothCharacteristic;
  BluetoothService? _heartRateData;
  late DeviceSelectorViewModel _deviceSelectorViewModel;

  // Getters
  bool get bluetoothState => _bluetoothState;
  UserBluetoothDevice? get selectedDeviceId => _selectedDeviceId;
  BluetoothConnectionState? get connectionState => _connectionState;
  List<BluetoothService> get services => _services;
  BluetoothService? get bluetoothService => _bluetoothService;
  BluetoothCharacteristic? get bluetoothCharacteristic =>
      _bluetoothCharacteristic;
  BluetoothService? get heartRateData => _heartRateData;
  DeviceSelectorViewModel get deviceSelectorViewModel =>
      _deviceSelectorViewModel;

  void init() {
    _deviceSelectorViewModel = DeviceSelectorViewModel();
    _deviceSelectorViewModel.init();
    getPermissions().then((_) {
      _startScan();
      _scanTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        _startScan();
        if (_selectedDeviceId != null && _selectedDeviceId!.device != null) {
          _connectionStateStream(_selectedDeviceId!.device!);
          _getServices(_selectedDeviceId!.device!);
        }
      });
    });
  }

  void updateBluetoothState(bool isOn) {
    _bluetoothState = isOn;
    notifyListeners();
  }

  void selectDevice(UserBluetoothDevice device) {
    _selectedDeviceId = device;
    notifyListeners();
  }

  Future<void> getPermissions() async {
    try {
      await Permission.bluetooth.request();
    } catch (e) {
      // TODO: Handle the exception properly, e.g., show a dialog to the user or log the error.
      print(e.toString());
    }
  }

  Future<void> _startScan() async {
    if (!(await FlutterBluePlus.isScanning.first)) {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
    }
  }

  Future<void> _getServices(BluetoothDevice device) async {
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
      notifyListeners();
    } catch (e) {
      // TODO: Handle the exception properly, e.g., show a dialog to the user or log the error.
      print(e.toString());
    }
  }

  Future<void> _connectionStateStream(BluetoothDevice device) async {
    try {
      await device
          .connect(license: License.free)
          .then((value) {
            device.connectionState.listen((event) async {
              if (event == BluetoothConnectionState.connected) {
                _connectionState = BluetoothConnectionState.connected;
              } else if (event == BluetoothConnectionState.disconnected) {
                _connectionState = BluetoothConnectionState.disconnected;
              } else {
                _connectionState = null;
              }
              _deviceSelectorViewModel.updateDeviceState(
                connectionState: _connectionState,
                services: _services,
              );
              notifyListeners();
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
  void dispose() {
    _scanTimer?.cancel();
    _deviceSelectorViewModel.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }
}
