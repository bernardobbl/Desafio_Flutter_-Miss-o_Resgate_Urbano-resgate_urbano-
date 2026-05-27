import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String mensagem;
  const EmptyState({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 72, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(mensagem, style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
