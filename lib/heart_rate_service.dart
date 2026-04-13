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
            final data = snapshot.data!;
            int heartRate;
            if ((data[0] & 0x01) == 0) {
              // Heart Rate is in the second byte
              heartRate = data[1];
            } else {
              // Heart Rate is in the second and third bytes
              heartRate = (data[1] << 8) | data[2];
            }
            return Text("Heart Rate: $heartRate bpm");
          } else {
            return Text("Waiting for heart rate data...");
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
