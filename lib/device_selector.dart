import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class UserBluetoothDevice {
  final String deviceId;
  final String deviceName;
  final BluetoothDevice? device;
  final Stream<BluetoothConnectionState>? connectionState;

  UserBluetoothDevice({
    required this.deviceId,
    required this.deviceName,
    required this.device,
    required this.connectionState,
  });
}

class DeviceSelector extends StatelessWidget {
  const DeviceSelector({
    super.key,
    required this.selectedDevice,
    required this.onDeviceSelected,
    required this.deviceConnectionState,
    required this.services,
  });

  final UserBluetoothDevice? selectedDevice;
  final void Function(UserBluetoothDevice) onDeviceSelected;
  final BluetoothConnectionState? deviceConnectionState;
  final List<BluetoothService> services;

  @override
  Widget build(BuildContext context) {
    if (selectedDevice != null) {
      return Column(
        children: [
          Text("Selected Device:"),
          Text(selectedDevice!.deviceName),
          Text(selectedDevice!.deviceId),
          Text(
            "Connection State: ${deviceConnectionState.toString().split('.').last}",
          ),
          Text(
            "Services: ${services.map((s) => s.uuid.toString()).join(', ')}",
          ),
        ],
      );
    }
    return StreamBuilder<List<ScanResult>>(
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
              onTap: () => onDeviceSelected(
                UserBluetoothDevice(
                  deviceId: r.device.remoteId.toString(),
                  deviceName: r.device.platformName,
                  device: r.device,
                  connectionState: r.device.connectionState,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
