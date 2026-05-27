import 'package:flutter/material.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/chamado.dart';
import 'priority_badge.dart';
import 'status_chip.dart';

class ChamadoTile extends StatelessWidget {
  final Chamado chamado;
  final VoidCallback onTap;
  final VoidCallback? onFavorito;

  const ChamadoTile({
    super.key,
    required this.chamado,
    required this.onTap,
    this.onFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final isCritico = chamado.prioridade == Prioridade.critica;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: isCritico ? Border.all(color: const Color(0xFFB71C1C), width: 1.5) : null,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(chamado.categoria.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chamado.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onFavorito != null)
                      GestureDetector(
                        onTap: onFavorito,
                        child: Icon(
                          chamado.favorito ? Icons.star : Icons.star_border,
                          color: chamado.favorito ? Colors.amber : Colors.grey,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    PriorityBadge(chamado.prioridade),
                    const SizedBox(width: 6),
                    StatusChip(chamado.status),
                    const Spacer(),
                    Icon(Icons.location_on, size: 13, color: Colors.grey[600]),
                    const SizedBox(width: 2),
                    Text(chamado.bairro, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
                    const SizedBox(width: 3),
                    Text(
                      AppDateUtils.tempoDecorrido(chamado.dataCriacao),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const Spacer(),
                    Text(
                      chamado.categoria.label,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
