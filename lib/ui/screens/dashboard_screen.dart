import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/chamado_provider.dart';
import '../components/empty_state.dart';
import '../widgets/chamado_tile.dart';
import '../widgets/critical_alert_banner.dart';
import '../widgets/stat_card.dart';
import 'chamado_form_screen.dart';
import 'chamado_detail_screen.dart';
import 'charts_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late Timer _timer;
  DateTime _agora = DateTime.now();
  final _searchController = TextEditingController();
  bool _searchVisible = false;

  late AnimationController _headerController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _headerFade = CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _agora = DateTime.now());
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ChamadoProvider>().carregar();
      _headerController.forward();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    _headerController.dispose();
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
            : const Text('Resgate Urbano',
                style: TextStyle(fontWeight: FontWeight.bold)),
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
            icon: Icon(themeProvider.isDark
                ? Icons.wb_sunny
                : Icons.nightlight_round),
            onPressed: themeProvider.toggle,
            tooltip: 'Alternar tema',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChartsScreen()),
            ),
            tooltip: 'Gráficos',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            tooltip: 'Configurações',
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner de alerta crítico animado
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: provider.alertaCriticos
                ? CriticalAlertBanner(
                    key: const ValueKey('banner'),
                    count: provider.totalCriticos)
                : const SizedBox.shrink(key: ValueKey('no-banner')),
          ),

          // Header com data/hora e total — entra com slide+fade
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: _buildHeader(theme),
            ),
          ),

          // Cards de estatísticas com fade
          FadeTransition(
            opacity: _headerFade,
            child: _buildStatCards(provider),
          ),

          // Filtro de bairros
          if (provider.bairrosDisponiveis.isNotEmpty)
            _buildBairroFilter(provider),

          // Lista animada
          Expanded(child: _buildLista(provider)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChamadoFormScreen()),
        ).then((_) => provider.carregar()),
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
              Text(
                AppDateUtils.formatDate(_agora),
                style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              Text(
                '${_agora.hour.toString().padLeft(2, '0')}:'
                '${_agora.minute.toString().padLeft(2, '0')}:'
                '${_agora.second.toString().padLeft(2, '0')}',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary),
              ),
            ],
          ),
          const Spacer(),
          Consumer<ChamadoProvider>(
            builder: (_, p, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${p.total}',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary),
                ),
                Text(
                  'chamados',
                  style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards(ChamadoProvider p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              label: 'Abertos',
              value: p.totalAbertos,
              color: AppTheme.statusColor(0),
              icon: Icons.radio_button_unchecked,
              selected: p.filtroStatus == Status.aberto,
              onTap: () => p.setFiltroStatus(
                  p.filtroStatus == Status.aberto ? null : Status.aberto),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Andamento',
              value: p.totalEmAndamento,
              color: AppTheme.statusColor(1),
              icon: Icons.autorenew,
              selected: p.filtroStatus == Status.emAndamento,
              onTap: () => p.setFiltroStatus(
                  p.filtroStatus == Status.emAndamento
                      ? null
                      : Status.emAndamento),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Concluídos',
              value: p.totalConcluidos,
              color: AppTheme.statusColor(2),
              icon: Icons.check_circle_outline,
              selected: p.filtroStatus == Status.concluido,
              onTap: () => p.setFiltroStatus(
                  p.filtroStatus == Status.concluido ? null : Status.concluido),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatCard(
              label: 'Críticos',
              value: p.totalCriticos,
              color: AppTheme.prioridadeColor(3),
              icon: Icons.priority_high,
              selected: false,
            ),
          ),
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
                  onSelected: (_) =>
                      p.setFiltroBairro(p.filtroBairro == b ? null : b),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLista(ChamadoProvider p) {
    if (p.carregando) {
      return const Center(child: CircularProgressIndicator());
    }
    final lista = p.chamadosFiltrados;
    if (lista.isEmpty) {
      return const EmptyState(mensagem: 'Nenhum chamado encontrado');
    }

    // AnimatedList substituído por ListView com animação por item
    return ListView.builder(
      itemCount: lista.length,
      itemBuilder: (_, i) {
        final c = lista[i];
        return _AnimatedTile(
          key: ValueKey(c.id),
          index: i,
          child: ChamadoTile(
            chamado: c,
            onFavorito: () => p.toggleFavorito(c.id),
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, anim, __) =>
                    ChamadoDetailScreen(chamadoId: c.id),
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0.05, 0), end: Offset.zero)
                        .animate(anim),
                    child: child,
                  ),
                ),
              ),
            ).then((_) => p.carregar()),
          ),
        );
      },
    );
  }
}

class _AnimatedTile extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedTile({super.key, required this.index, required this.child});

  @override
  State<_AnimatedTile> createState() => _AnimatedTileState();
}

class _AnimatedTileState extends State<_AnimatedTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger baseado no índice (máximo 300ms de delay)
    final delay = Duration(milliseconds: (widget.index * 60).clamp(0, 300));
    Future.delayed(delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
