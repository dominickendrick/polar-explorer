import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'heart_rate_view_model.dart';

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
  final _viewModel = HeartRateViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.update(
      service: widget.heartRateService,
      connectionState: widget.connectionState,
    );
  }

  @override
  void didUpdateWidget(HeartRateService oldWidget) {
    super.didUpdateWidget(oldWidget);
    _viewModel.update(
      service: widget.heartRateService,
      connectionState: widget.connectionState,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return switch (_viewModel.status) {
          HeartRateStatus.disconnected => Text("Not connected to a device."),
          HeartRateStatus.serviceNotFound =>
            Text("Heart Rate Service not found on the device."),
          HeartRateStatus.monitoring =>
            Text("Heart Rate: ${_viewModel.heartRate ?? '-'} bpm"),
        };
      },
    );
  }
}
