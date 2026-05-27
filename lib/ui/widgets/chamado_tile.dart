import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../core/constants/enums.dart';
import '../../data/models/chamado.dart';
import 'priority_badge.dart';
import 'status_chip.dart';

class ChamadoTile extends StatelessWidget {
  final Chamado chamado;
  final VoidCallback onTap;
  final VoidCallback onFavorito;

  const ChamadoTile({
    super.key,
    required this.chamado,
    required this.onTap,
    required this.onFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final prioridadeColor = AppTheme.prioridadeColor(chamado.prioridade.index);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone da categoria
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: prioridadeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(chamado.categoria.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + favorito
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chamado.titulo,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onFavorito,
                          child: Icon(
                            chamado.favorito ? Icons.star : Icons.star_border,
                            size: 18,
                            color: chamado.favorito ? Colors.amber : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Badges
                    Row(
                      children: [
                        PriorityBadge(chamado.prioridade),
                        const SizedBox(width: 6),
                        StatusChip(chamado.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Bairro + tempo
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(
                          chamado.bairro,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time, size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Text(
                          AppDateUtils.tempoDecorrido(chamado.dataCriacao),
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
