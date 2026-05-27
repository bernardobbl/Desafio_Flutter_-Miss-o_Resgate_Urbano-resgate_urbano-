import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/validators.dart';
import '../../data/models/chamado.dart';
import '../../providers/chamado_provider.dart';

class ChamadoFormScreen extends StatefulWidget {
  final Chamado? chamado;
  const ChamadoFormScreen({super.key, this.chamado});

  @override
  State<ChamadoFormScreen> createState() => _ChamadoFormScreenState();
}

class _ChamadoFormScreenState extends State<ChamadoFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late final TextEditingController _titulo;
  late final TextEditingController _descricao;
  late final TextEditingController _bairro;
  late final TextEditingController _responsavel;

  late Categoria _categoria;
  late Prioridade _prioridade;
  late Status _status;
  late DateTime _dataCriacao;
  bool _salvando = false;

  bool get _editando => widget.chamado != null;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    final c = widget.chamado;
    _titulo = TextEditingController(text: c?.titulo ?? '');
    _descricao = TextEditingController(text: c?.descricao ?? '');
    _bairro = TextEditingController(text: c?.bairro ?? '');
    _responsavel = TextEditingController(text: c?.responsavel ?? '');
    _categoria = c?.categoria ?? Categoria.transito;
    _prioridade = c?.prioridade ?? Prioridade.media;
    _status = c?.status ?? Status.aberto;
    _dataCriacao = c?.dataCriacao ?? DateTime.now();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _titulo.dispose();
    _descricao.dispose();
    _bairro.dispose();
    _responsavel.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    final provider = context.read<ChamadoProvider>();

    String? erro;
    if (_editando) {
      final atualizado = widget.chamado!.copyWith(
        titulo: _titulo.text,
        descricao: _descricao.text,
        categoria: _categoria,
        prioridade: _prioridade,
        bairro: _bairro.text,
        responsavel: _responsavel.text,
        dataCriacao: _dataCriacao,
        status: _status,
      );
      erro = await provider.editar(atualizado);
    } else {
      erro = await provider.criar(
        titulo: _titulo.text,
        descricao: _descricao.text,
        categoria: _categoria,
        prioridade: _prioridade,
        bairro: _bairro.text,
        responsavel: _responsavel.text,
        dataCriacao: _dataCriacao,
      );
    }

    if (!mounted) return;
    setState(() => _salvando = false);
    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(erro), backgroundColor: Colors.red));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChamadoProvider>();
    final bairrosExistentes = provider.bairrosDisponiveis;

    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar Chamado' : 'Novo Chamado')),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titulo,
              decoration: const InputDecoration(labelText: 'Título *', prefixIcon: Icon(Icons.title)),
              validator: (v) => Validators.required(v, 'Título'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descricao,
              decoration: const InputDecoration(labelText: 'Descrição *', prefixIcon: Icon(Icons.description), alignLabelWithHint: true),
              maxLines: 3,
              validator: (v) => Validators.required(v, 'Descrição'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),
            // Categoria
            DropdownButtonFormField<Categoria>(
              value: _categoria,
              decoration: const InputDecoration(labelText: 'Categoria *', prefixIcon: Icon(Icons.category)),
              items: Categoria.values.map((c) => DropdownMenuItem(
                value: c,
                child: Row(children: [Text(c.icon), const SizedBox(width: 8), Text(c.label)]),
              )).toList(),
              onChanged: (v) => setState(() => _categoria = v!),
            ),
            const SizedBox(height: 14),
            // Prioridade
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prioridade *', style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
                const SizedBox(height: 8),
                SegmentedButton<Prioridade>(
                  segments: Prioridade.values.map((p) => ButtonSegment<Prioridade>(value: p, label: Text(p.label, style: const TextStyle(fontSize: 12)))).toList(),
                  selected: {_prioridade},
                  onSelectionChanged: (v) => setState(() => _prioridade = v.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) return null;
                      return null;
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Bairro com autocomplete
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _bairro.text),
              optionsBuilder: (v) => bairrosExistentes.where((b) => b.toLowerCase().contains(v.text.toLowerCase())),
              onSelected: (v) => _bairro.text = v,
              fieldViewBuilder: (ctx, ctrl, fn, onSub) {
                _bairro.text = ctrl.text;
                return TextFormField(
                  controller: ctrl,
                  focusNode: fn,
                  decoration: const InputDecoration(labelText: 'Bairro *', prefixIcon: Icon(Icons.location_city)),
                  validator: (_) => Validators.required(_bairro.text, 'Bairro'),
                  onChanged: (v) => _bairro.text = v,
                  textCapitalization: TextCapitalization.words,
                );
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _responsavel,
              decoration: const InputDecoration(labelText: 'Responsável *', prefixIcon: Icon(Icons.person)),
              validator: (v) => Validators.required(v, 'Responsável'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),
            // Status (só na edição)
            if (_editando)
              DropdownButtonFormField<Status>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status *', prefixIcon: Icon(Icons.flag)),
                items: Status.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
            if (_editando) const SizedBox(height: 14),
            // Data
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Data de Abertura'),
              subtitle: Text(_dataCriacao.toString().substring(0, 16)),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dataCriacao,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _dataCriacao = d);
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _salvando ? null : _salvar,
              icon: _salvando ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
              label: Text(_editando ? 'Salvar Alterações' : 'Cadastrar Chamado'),
              style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
        ),
    );
  }
}
