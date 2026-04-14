import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum HeartRateStatus { disconnected, serviceNotFound, monitoring }

class HeartRateViewModel extends ChangeNotifier {
  int? _heartRate;
  BluetoothConnectionState? _connectionState;
  BluetoothService? _bluetoothPolarService;
  BluetoothCharacteristic? _bluetoothCharacteristic;
  StreamSubscription<List<int>>? _heartRateStreamSubscription;

  int? get heartRate => _heartRate;

  HeartRateStatus get status {
    if (_connectionState != BluetoothConnectionState.connected) {
      return HeartRateStatus.disconnected;
    }
    if (_bluetoothPolarService == null) {
      return HeartRateStatus.serviceNotFound;
    }
    return HeartRateStatus.monitoring;
  }

  Future<void> update({
    required BluetoothService? service,
    required BluetoothConnectionState? connectionState,
  }) async {
    _connectionState = connectionState;

    final serviceChanged =
        service?.serviceUuid != _bluetoothPolarService?.serviceUuid;
    if (serviceChanged) {
      _bluetoothPolarService = service;
      await _subscribe(service);
    }

    notifyListeners();
  }

  Future<void> _subscribe(BluetoothService? service) async {
    _heartRateStreamSubscription?.cancel();
    _heartRateStreamSubscription = null;
    _bluetoothCharacteristic = null;
    _heartRate = null;

    if (service == null) return;

    final bluetoothCharacteristic = service.characteristics
        .where((c) => c.uuid.toString().toLowerCase().contains("2a37"))
        .firstOrNull;
    if (bluetoothCharacteristic == null) return;

    await bluetoothCharacteristic.setNotifyValue(true);
    _bluetoothCharacteristic = bluetoothCharacteristic;

    _heartRateStreamSubscription = bluetoothCharacteristic.lastValueStream
        .listen((data) {
          if (data.length >= 2) {
            _heartRate = _parseHeartRate(data);
            notifyListeners();
          }
        });
  }

  @override
  void dispose() {
    _heartRateStreamSubscription?.cancel();
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
