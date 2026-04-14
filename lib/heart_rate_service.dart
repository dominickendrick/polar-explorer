import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'heart_rate_view_model.dart';
import 'zone_indicator.dart';

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

  String _formatZoneName(HeartRateZone? zone) {
    if (zone == null) return '- -';
    final name = zone.name;
    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final heartRate = _viewModel.heartRate;
        final displayValue = heartRate != null ? heartRate.toString() : '- -';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Current zone + pill + chevron
            Row(
              children: [
                const Text(
                  'Current zone',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatZoneName(_viewModel.zone),
                  style: const TextStyle(color: Colors.white),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: Colors.white, size: 24),
              ],
            ),
            const SizedBox(height: 24),
            // Bottom row: Heart rate + bpm + zone bars
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    displayValue,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'bpm',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: ZoneIndicator(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
