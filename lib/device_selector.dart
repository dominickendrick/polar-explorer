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
        Text("Selected Device:"),
        Text(vm.selectedDevice!.deviceName),
        Text(vm.selectedDevice!.deviceId),
        Text(
          "Connection State: ${vm.connectionState.toString().split('.').last}",
        ),
        Text(
          "Services: ${vm.services.map((s) => s.uuid.toString()).join(', ')}",
        ),
      ],
    );
  }

  Widget _buildScanResults() {
    final results = widget.viewModel.scanResults;
    return Column(
      children: results.map((r) {
        return ListTile(
          title: Text(r.device.platformName),
          subtitle: Text(r.device.remoteId.toString()),
          trailing: Text(r.rssi.toString()),
          onTap: () {
            widget.viewModel.selectDevice(r);
            widget.onDeviceSelected(widget.viewModel.selectedDevice!);
          },
        );
      }).toList(),
    );
  }
}
