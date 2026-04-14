import 'package:flutter/material.dart';

class ZoneIndicator extends StatelessWidget {
  const ZoneIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
