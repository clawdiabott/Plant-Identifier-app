import 'package:flutter/material.dart';

import '../models/disease_report.dart';

class SeverityChip extends StatelessWidget {
  const SeverityChip({super.key, required this.severity});

  final SeverityLevel severity;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(severity.name.toUpperCase()),
      backgroundColor: _color(context).withOpacity(0.2),
      side: BorderSide(color: _color(context)),
      labelStyle: TextStyle(color: _color(context), fontWeight: FontWeight.bold),
    );
  }

  Color _color(BuildContext context) {
    switch (severity) {
      case SeverityLevel.low:
        return Colors.green;
      case SeverityLevel.medium:
        return Colors.orange;
      case SeverityLevel.high:
        return Colors.deepOrange;
      case SeverityLevel.critical:
        return Colors.red;
    }
  }
}
