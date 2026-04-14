import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConnectionStateCard extends StatelessWidget {
  const ConnectionStateCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textHeight = DefaultTextStyle.of(context).style.fontSize ?? 14;
    final twoRowsHeight = textHeight * 2 * 1.5; // 2 rows with 1.5 line height

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: twoRowsHeight + 32,
      ), // +32 for padding
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(7, 10, 33, 1.0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          SvgPicture.asset('assets/icons/pair_band.svg', width: 40, height: 40),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
