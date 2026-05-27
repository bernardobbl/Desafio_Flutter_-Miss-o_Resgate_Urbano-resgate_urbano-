import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final Status status;

  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status.index);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(status.label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
