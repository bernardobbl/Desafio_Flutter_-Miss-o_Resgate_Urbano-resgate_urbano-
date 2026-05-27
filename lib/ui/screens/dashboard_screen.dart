import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/chamado.dart';
import '../../providers/chamado_provider.dart';
import '../components/empty_state.dart';
import '../widgets/chamado_tile.dart';
import '../widgets/critical_alert_banner.dart';
import '../widgets/stat_card.dart';
import 'chamado_form_screen.dart';
import 'chamado_detail_screen.dart';
import 'charts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Timer _timer;
  DateTime _agora = DateTime.now();
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _agora = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChamadoProvider>().carregar();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final provider = context.watch<ChamadoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: _searchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Buscar chamados...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: provider.setBusca,
              )
            : const Text('Resgate Urbano', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_searchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searchVisible = !_searchVisible);
              if (!_searchVisible) {
                _searchController.clear();
                provider.setBusca('');
              }
            },
          ),
          IconButton(
            icon: Icon(themeProvider.isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: themeProvider.toggle,
            tooltip: 'Alternar tema',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChartsScreen())),
            tooltip: 'Gráficos',
          ),
        ],
      ),
      body: Column(
        children: [
          // Alerta críticos
          if (provider.alertaCriticos) CriticalAlertBanner(count: provider.totalCriticos),

          // Header com data e total
          _buildHeader(theme),

          // Cards de estatísticas
          _buildStatCards(provider),

          // Filtro de bairros
          if (provider.bairrosDisponiveis.isNotEmpty) _buildBairroFilter(provider),

          // Lista
          Expanded(child: _buildLista(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChamadoFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Novo Chamado'),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppDateUtils.formatDate(_agora),
                  style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.6))),
              Text(
                '${_agora.hour.toString().padLeft(2, '0')}:${_agora.minute.toString().padLeft(2, '0')}:${_agora.second.toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
              ),
            ],
          ),
          const Spacer(),
          Consumer<ChamadoProvider>(builder: (_, p, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${p.total}', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
              Text('chamados', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatCards(ChamadoProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: StatCard(
            label: 'Abertos', value: p.totalAbertos,
            color: AppTheme.statusColor(0), icon: Icons.radio_button_unchecked,
            selected: p.filtroStatus == Status.aberto,
            onTap: () => p.setFiltroStatus(p.filtroStatus == Status.aberto ? null : Status.aberto),
          )),
          const SizedBox(width: 8),
          Expanded(child: StatCard(
            label: 'Andamento', value: p.totalEmAndamento,
            color: AppTheme.statusColor(1), icon: Icons.autorenew,
            selected: p.filtroStatus == Status.emAndamento,
            onTap: () => p.setFiltroStatus(p.filtroStatus == Status.emAndamento ? null : Status.emAndamento),
          )),
          const SizedBox(width: 8),
          Expanded(child: StatCard(
            label: 'Concluídos', value: p.totalConcluidos,
            color: AppTheme.statusColor(2), icon: Icons.check_circle_outline,
            selected: p.filtroStatus == Status.concluido,
            onTap: () => p.setFiltroStatus(p.filtroStatus == Status.concluido ? null : Status.concluido),
          )),
          const SizedBox(width: 8),
          Expanded(child: StatCard(
            label: 'Críticos', value: p.totalCriticos,
            color: AppTheme.prioridadeColor(3), icon: Icons.priority_high,
            selected: false,
          )),
        ],
      ),
    );
  }

  Widget _buildBairroFilter(ChamadoProvider p) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        children: [
          if (p.filtroBairro != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                label: const Text('Limpar'),
                avatar: const Icon(Icons.close, size: 14),
                onPressed: () => p.setFiltroBairro(null),
              ),
            ),
          ...p.bairrosDisponiveis.map((b) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(b),
              selected: p.filtroBairro == b,
              onSelected: (_) => p.setFiltroBairro(p.filtroBairro == b ? null : b),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildLista(ChamadoProvider p) {
    if (p.carregando) return const Center(child: CircularProgressIndicator());
    final lista = p.chamadosFiltrados;
    if (lista.isEmpty) return const EmptyState(mensagem: 'Nenhum chamado encontrado');
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (_, i) {
        final c = lista[i];
        return ChamadoTile(
          chamado: c,
          onFavorito: () => p.toggleFavorito(c.id),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChamadoDetailScreen(chamadoId: c.id)),
          ),
        );
      },
    );
  }
}
