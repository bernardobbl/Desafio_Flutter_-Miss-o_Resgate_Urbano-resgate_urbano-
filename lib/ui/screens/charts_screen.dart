import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/chamado_provider.dart';

class ChartsScreen extends StatelessWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ChamadoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Gráficos & Ranking')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Chamados por Categoria'),
          const SizedBox(height: 8),
          _CategoriaChart(data: p.porCategoria),
          const SizedBox(height: 24),
          _SectionTitle('Ranking de Bairros (Top 5)'),
          const SizedBox(height: 8),
          _RankingBairros(ranking: p.rankingBairros),
          const SizedBox(height: 24),
          _SectionTitle('Chamados por Status'),
          const SizedBox(height: 8),
          _StatusPieChart(abertos: p.totalAbertos, andamento: p.totalEmAndamento, concluidos: p.totalConcluidos),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary));
}

class _CategoriaChart extends StatelessWidget {
  final Map<Categoria, int> data;
  const _CategoriaChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Text('Sem dados');
    final entries = data.entries.toList();
    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (entries.map((e) => e.value).reduce((a, b) => a > b ? a : b) + 2).toDouble(),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= entries.length) return const SizedBox();
                  return Text(entries[idx].key.icon, style: const TextStyle(fontSize: 16));
                },
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          barGroups: entries.asMap().entries.map((e) {
            final colors = [
              const Color(0xFF1976D2), const Color(0xFFFFA726), const Color(0xFF26A69A),
              const Color(0xFFEF5350), const Color(0xFF66BB6A), const Color(0xFFAB47BC),
            ];
            return BarChartGroupData(x: e.key, barRods: [
              BarChartRodData(toY: e.value.value.toDouble(), color: colors[e.key % colors.length], width: 22, borderRadius: BorderRadius.circular(6)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _RankingBairros extends StatelessWidget {
  final List<MapEntry<String, int>> ranking;
  const _RankingBairros({required this.ranking});

  @override
  Widget build(BuildContext context) {
    if (ranking.isEmpty) return const Text('Sem dados');
    final max = ranking.first.value;
    return Column(
      children: ranking.asMap().entries.map((e) {
        final posicao = e.key + 1;
        final entry = e.value;
        final medals = ['🥇', '🥈', '🥉'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(posicao <= 3 ? medals[posicao - 1] : '#$posicao', style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${entry.value} chamados', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: entry.value / max,
                      backgroundColor: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatusPieChart extends StatefulWidget {
  final int abertos, andamento, concluidos;
  const _StatusPieChart({required this.abertos, required this.andamento, required this.concluidos});

  @override
  State<_StatusPieChart> createState() => _StatusPieChartState();
}

class _StatusPieChartState extends State<_StatusPieChart> {
  int _touched = -1;

  @override
  Widget build(BuildContext context) {
    final total = widget.abertos + widget.andamento + widget.concluidos;
    if (total == 0) return const Text('Sem dados');
    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (_, r) => setState(() => _touched = r?.touchedSection?.touchedSectionIndex ?? -1),
                ),
                sections: [
                  _section(widget.abertos, total, AppTheme.statusColor(0), 'Abertos', 0),
                  _section(widget.andamento, total, AppTheme.statusColor(1), 'Andamento', 1),
                  _section(widget.concluidos, total, AppTheme.statusColor(2), 'Concluídos', 2),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legend(AppTheme.statusColor(0), 'Abertos', widget.abertos),
              _legend(AppTheme.statusColor(1), 'Andamento', widget.andamento),
              _legend(AppTheme.statusColor(2), 'Concluídos', widget.concluidos),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _section(int v, int total, Color color, String title, int idx) {
    final touched = idx == _touched;
    return PieChartSectionData(
      value: v.toDouble(),
      color: color,
      radius: touched ? 60 : 50,
      title: v == 0 ? '' : '${(v / total * 100).toStringAsFixed(0)}%',
      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _legend(Color color, String label, int count) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text('$label ($count)', style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
