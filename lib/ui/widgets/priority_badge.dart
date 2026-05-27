import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';

class PriorityBadge extends StatelessWidget {
  final Prioridade prioridade;

  const PriorityBadge(this.prioridade, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.prioridadeColor(prioridade.index);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        prioridade.label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
