import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HeartRateViewModel extends ChangeNotifier {
  int? _heartRate;
  BluetoothConnectionState? _connectionState;
  BluetoothService? _service;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription<List<int>>? _subscription;

  int? get heartRate => _heartRate;

  String get statusText {
    if (_connectionState != BluetoothConnectionState.connected) {
      return "Not connected to a device.";
    }
    if (_service == null) {
      return "Heart Rate Service not found on the device.";
    }

    return "Heart Rate: $_heartRate bpm";
  }

  Future<void> update({
    required BluetoothService? service,
    required BluetoothConnectionState? connectionState,
  }) async {
    _connectionState = connectionState;

    final serviceChanged = service?.serviceUuid != _service?.serviceUuid;
    if (serviceChanged) {
      _service = service;
      await _subscribe(service);
    }

    notifyListeners();
  }

  Future<void> _subscribe(BluetoothService? service) async {
    _subscription?.cancel();
    _subscription = null;
    _characteristic = null;
    _heartRate = null;

    if (service == null) return;

    final characteristic = service.characteristics
        .where((c) => c.uuid.toString().toLowerCase().contains("2a37"))
        .firstOrNull;
    if (characteristic == null) return;

    await characteristic.setNotifyValue(true);
    _characteristic = characteristic;

    _subscription = characteristic.lastValueStream.listen((data) {
      if (data.length >= 2) {
        _heartRate = _parseHeartRate(data);
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

int _parseHeartRate(List<int> data) {
  // Bit 0 of the flags byte indicates heart rate value format:
  // 0 = UINT8 (single byte), 1 = UINT16 (two bytes)
  // data[0] & 0x01 is a bitwise AND — it masks all bits except bit 0 (the least significant bit). So it isolates just that single bit from the flags byte.

  // For example, if `data[0]` is `22` (binary `00010110`):

  //  `00010110`
  //`& 00000001`
  // ----------
  //   00000000  → result is 0

  // The `== 0` check then determines which branch to take: if bit 0 is `0`, the heart rate is a single byte; if it's 1, it's two bytes.
  if ((data[0] & 0x01) == 0) {
    // Heart Rate is in the second byte
    return data[1];
  } else {
    // Heart Rate is in the second and third bytes
    return (data[1] << 8) | data[2];
  }
}
