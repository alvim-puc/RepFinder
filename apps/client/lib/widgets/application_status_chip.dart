import 'package:flutter/material.dart';

class ApplicationStatusChip extends StatelessWidget {
  final String status;

  const ApplicationStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'accepted':
        backgroundColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'Aceita';
        break;
      case 'rejected':
        backgroundColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'Recusada';
        break;
      case 'pending':
      default:
        backgroundColor = Colors.grey.shade200;
        textColor = Colors.grey.shade700;
        label = 'Pendente';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
