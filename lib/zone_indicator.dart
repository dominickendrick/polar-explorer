import 'package:flutter/material.dart';

class ZoneIndicator extends StatelessWidget {
  const ZoneIndicator({super.key, this.heartRate});

  final int? heartRate;

  // Maps heart rate to a position from 0.0 to 1.0
  double _calculatePosition() {
    final hr = heartRate;
    if (hr == null) return 0.0;

    const minHr = 40;
    const maxHr = 180;
    final clamped = hr.clamp(minHr, maxHr);
    return (clamped - minHr) / (maxHr - minHr);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final position = _calculatePosition();
          final circleSize = 20.0;
          final maxOffset = constraints.maxWidth - circleSize;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(142, 136, 89, 1.0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(91, 101, 148, 1.0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(156, 140, 154, 1.0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: position * maxOffset,
                top: -6,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(24, 26, 66, 1.0),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
