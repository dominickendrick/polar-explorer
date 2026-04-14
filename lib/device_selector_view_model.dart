import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_selector.dart';

enum DeviceSelectorStatus { scanning, deviceSelected }

class DeviceSelectorViewModel extends ChangeNotifier {
  UserBluetoothDevice? _selectedDevice;
  BluetoothConnectionState? _connectionState;
  List<BluetoothService> _services = [];
  List<ScanResult> _scanResults = [];
  Set<String> _seenDeviceIds = {};
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  UserBluetoothDevice? get selectedDevice => _selectedDevice;
  BluetoothConnectionState? get connectionState => _connectionState;
  List<BluetoothService> get services => _services;
  List<ScanResult> get scanResults => _scanResults;

  DeviceSelectorStatus get status {
    if (_selectedDevice != null) {
      return DeviceSelectorStatus.deviceSelected;
    }
    return DeviceSelectorStatus.scanning;
  }

  void init() {
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      bool hasNewDevices = false;
      for (final result in results) {
        if (result.device.platformName.contains("Polar")) {
          final deviceId = result.device.remoteId.toString();
          if (!_seenDeviceIds.contains(deviceId)) {
            _seenDeviceIds.add(deviceId);
            _scanResults.add(result);
            hasNewDevices = true;
          } else {
            // Update existing device with latest scan result
            final index = _scanResults.indexWhere(
              (r) => r.device.remoteId.toString() == deviceId,
            );
            if (index != -1) {
              _scanResults[index] = result;
              hasNewDevices = true;
            }
          }
        }
      }
      if (hasNewDevices) {
        notifyListeners();
      }
    });
  }

  void selectDevice(ScanResult result) {
    _selectedDevice = UserBluetoothDevice(
      deviceId: result.device.remoteId.toString(),
      deviceName: result.device.platformName,
      device: result.device,
      connectionState: result.device.connectionState,
    );
    notifyListeners();
  }

  void updateDeviceState({
    required BluetoothConnectionState? connectionState,
    required List<BluetoothService> services,
  }) {
    _connectionState = connectionState;
    _services = services;
    notifyListeners();
  }

  void clearScanResults() {
    _scanResults.clear();
    _seenDeviceIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanResults.clear();
    _seenDeviceIds.clear();
    super.dispose();
  }
}
