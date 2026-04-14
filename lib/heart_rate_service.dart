import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class HeartRateService extends StatefulWidget {
  const HeartRateService({
    super.key,
    required this.heartRateService,
    required this.connectionState,
  });

  final BluetoothService? heartRateService;
  final BluetoothConnectionState? connectionState;

  @override
  State<HeartRateService> createState() => _HeartRateServiceState();
}

class _HeartRateServiceState extends State<HeartRateService> {
  BluetoothCharacteristic? _characteristic;

  @override
  void didUpdateWidget(HeartRateService oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.heartRateService != oldWidget.heartRateService) {
      _enableNotifications();
    }
  }

  @override
  void initState() {
    super.initState();
    _enableNotifications();
  }

  Future<void> _enableNotifications() async {
    final service = widget.heartRateService;
    if (service == null) return;

    final characteristic = service.characteristics
        .where((c) => c.uuid.toString().toLowerCase().contains("2a37"))
        .firstOrNull;
    if (characteristic == null) return;

    await characteristic.setNotifyValue(true);
    setState(() {
      _characteristic = characteristic;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.connectionState == BluetoothConnectionState.connected &&
        widget.heartRateService != null) {
      if (_characteristic == null) {
        return Text("Waiting for heart rate data...");
      }
      return StreamBuilder<List<int>>(
        stream: _characteristic!.lastValueStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.length >= 2) {
            final heartRate = _parseHeartRate(snapshot.data!);
            return Text("Heart Rate: $heartRate bpm");
          } else {
            return Text("-");
          }
        },
      );
    } else if (widget.connectionState == BluetoothConnectionState.connected) {
      return Text("Heart Rate Service not found on the device.");
    } else {
      return Text("Not connected to a device.");
    }
  }
}

int _parseHeartRate(List<int>? data) {
  if (data == null) return 0;
  int heartRate;
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
    heartRate = data[1];
  } else {
    // Heart Rate is in the second and third bytes
    heartRate = (data[1] << 8) | data[2];
  }
  return heartRate;
}
