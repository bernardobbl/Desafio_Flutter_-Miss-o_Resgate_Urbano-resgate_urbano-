import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/chamado_provider.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_chip.dart';
import 'chamado_form_screen.dart';

class ChamadoDetailScreen extends StatelessWidget {
  final String chamadoId;
  const ChamadoDetailScreen({super.key, required this.chamadoId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChamadoProvider>();
    final chamado = provider.getChamadoById(chamadoId);

    if (chamado == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhe')),
        body: const Center(child: Text('Chamado não encontrado')),
      );
    }

    final isConcluido = chamado.status == Status.concluido;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do Chamado'),
        actions: [
          IconButton(
            icon: Icon(
              chamado.favorito ? Icons.star : Icons.star_border,
              color: chamado.favorito ? Colors.amber : null,
            ),
            onPressed: () => provider.toggleFavorito(chamado.id),
          ),
          if (!isConcluido)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChamadoFormScreen(chamado: chamado)),
              ),
            ),
          PopupMenuButton<String>(
            itemBuilder: (_) => [
              if (!isConcluido && chamado.status != Status.emAndamento)
                const PopupMenuItem(value: 'andamento', child: Text('Marcar Em Andamento')),
              if (!isConcluido)
                const PopupMenuItem(value: 'concluido', child: Text('Marcar Concluído')),
              const PopupMenuItem(
                value: 'excluir',
                child: Text('Excluir', style: TextStyle(color: Colors.red)),
              ),
            ],
            onSelected: (v) async {
              if (v == 'andamento') {
                await provider.alterarStatus(chamado.id, Status.emAndamento);
              } else if (v == 'concluido') {
                await provider.alterarStatus(chamado.id, Status.concluido);
              } else if (v == 'excluir') {
                final confirma = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Excluir chamado?'),
                    content: const Text('Esta ação não pode ser desfeita.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                      FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
                    ],
                  ),
                );
                if (confirma == true && context.mounted) {
                  await provider.excluir(chamado.id);
                  if (context.mounted) Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(chamado.categoria.icon, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(chamado.titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(children: [PriorityBadge(chamado.prioridade), const SizedBox(width: 8), StatusChip(chamado.status)]),
                  ],
                ),
              ),
            ],
          ),
          if (isConcluido)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, color: Colors.orange, size: 16),
                  SizedBox(width: 8),
                  Text('Chamado concluído — edição bloqueada', style: TextStyle(color: Colors.orange, fontSize: 13)),
                ],
              ),
            ),
          const SizedBox(height: 20),
          const Divider(),
          _infoRow(Icons.description, 'Descrição', chamado.descricao),
          _infoRow(Icons.category, 'Categoria', chamado.categoria.label),
          _infoRow(Icons.location_on, 'Bairro', chamado.bairro),
          _infoRow(Icons.person, 'Responsável', chamado.responsavel),
          _infoRow(Icons.calendar_today, 'Data de Abertura', AppDateUtils.formatDateTime(chamado.dataCriacao)),
          _infoRow(Icons.access_time, 'Tempo Decorrido', AppDateUtils.tempoDecorrido(chamado.dataCriacao)),
          const Divider(),
          const SizedBox(height: 16),
          if (!isConcluido) ...[
            Text('Alterar Status',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 10),
            Row(
              children: [
                if (chamado.status != Status.emAndamento)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.autorenew, size: 18),
                      label: const Text('Em Andamento'),
                      onPressed: () => provider.alterarStatus(chamado.id, Status.emAndamento),
                    ),
                  ),
                if (chamado.status != Status.emAndamento) const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Concluir'),
                    onPressed: () => provider.alterarStatus(chamado.id, Status.concluido),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
