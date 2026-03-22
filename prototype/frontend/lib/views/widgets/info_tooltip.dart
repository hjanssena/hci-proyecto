import 'package:flutter/material.dart';

class InfoTooltip extends StatelessWidget {
  final String message;

  const InfoTooltip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: false,
      child: Icon(
        Icons.info_outline,
        size: 18,
        color: Colors.grey.shade600,
      ),
    );
  }
}
