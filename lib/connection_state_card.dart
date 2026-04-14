import 'package:flutter/material.dart';

class ConnectionStateCard extends StatelessWidget {
  const ConnectionStateCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(7, 10, 33, 1.0),
        borderRadius: BorderRadius.circular(5),
      ),
      child: child,
    );
  }
}
