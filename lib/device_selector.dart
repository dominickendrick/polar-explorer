import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'device_selector_view_model.dart';

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

class DeviceSelector extends StatefulWidget {
  const DeviceSelector({
    super.key,
    required this.viewModel,
    required this.onDeviceSelected,
  });

  final DeviceSelectorViewModel viewModel;
  final void Function(UserBluetoothDevice) onDeviceSelected;

  @override
  State<DeviceSelector> createState() => _DeviceSelectorState();
}

class _DeviceSelectorState extends State<DeviceSelector> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return switch (widget.viewModel.status) {
          DeviceSelectorStatus.deviceSelected => _buildSelectedDevice(),
          DeviceSelectorStatus.scanning => _buildScanResults(),
        };
      },
    );
  }

  Widget _buildSelectedDevice() {
    final vm = widget.viewModel;
    return Column(
      children: [
        Text(
          "Connecting to ${_parseDeviceName(vm.selectedDevice!.deviceName)}...",
        ),
      ],
    );
  }

  Widget _buildScanResults() {
    final results = widget.viewModel.scanResults;
    return Column(
      children: results.map((r) {
        return ListTile(
          title: Text(_parseDeviceName(r.device.platformName)),
          subtitle: Text("Polar device found - tap to connect"),
          onTap: () {
            widget.viewModel.selectDevice(r);
            widget.onDeviceSelected(widget.viewModel.selectedDevice!);
          },
        );
      }).toList(),
    );
  }

  String _parseDeviceName(String platformName) {
    final nameParts = platformName.split(' ');
    return nameParts.length >= 2
        ? '${nameParts[0]} ${nameParts[1]}'
        : platformName;
  }
}
