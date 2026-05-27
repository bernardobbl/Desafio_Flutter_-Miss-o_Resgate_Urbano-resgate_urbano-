import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme_provider.dart';
import '../../providers/chamado_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final provider = context.watch<ChamadoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          _SectionHeader('Aparência'),
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDark ? Icons.nightlight_round : Icons.wb_sunny,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('Modo Escuro'),
            subtitle: Text(themeProvider.isDark ? 'Ativado' : 'Desativado'),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggle(),
          ),
          const Divider(),
          _SectionHeader('Dados'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Total de chamados'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${provider.total}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Limpar todos os dados', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Remove todos os chamados permanentemente'),
            onTap: () => _confirmarLimpeza(context, provider),
          ),
          const Divider(),
          _SectionHeader('Sobre'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Resgate Urbano'),
            subtitle: Text('Versão 1.0.0 • Desafio Flutter 2026'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Tecnologias'),
            subtitle: Text('Flutter • Provider • SQLite'),
          ),
        ],
      ),
    );
  }

  void _confirmarLimpeza(BuildContext context, ChamadoProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar todos os dados?'),
        content: const Text(
          'Todos os chamados serão removidos permanentemente. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await provider.limparTudo();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Todos os dados foram removidos.')),
                );
              }
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
