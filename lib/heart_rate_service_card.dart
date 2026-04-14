import 'package:flutter/material.dart';

class HeartRateServiceCard extends StatelessWidget {
  const HeartRateServiceCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(32, 36, 82, 1.0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: child,
    );
  }
}
