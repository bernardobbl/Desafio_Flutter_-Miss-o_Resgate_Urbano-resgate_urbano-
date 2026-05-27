import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/enums.dart';
import '../../core/utils/date_utils.dart';
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
  late final List<String> _bairrosExistentes;

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

    // Snapshot dos bairros — não rebuilda o form a cada mudança do provider
    _bairrosExistentes = context.read<ChamadoProvider>().bairrosDisponiveis;
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
      erro = await provider.editar(widget.chamado!.copyWith(
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        categoria: _categoria,
        prioridade: _prioridade,
        bairro: _bairro.text.trim(),
        responsavel: _responsavel.text.trim(),
        dataCriacao: _dataCriacao,
        status: _status,
      ));
    } else {
      erro = await provider.criar(
        titulo: _titulo.text.trim(),
        descricao: _descricao.text.trim(),
        categoria: _categoria,
        prioridade: _prioridade,
        bairro: _bairro.text.trim(),
        responsavel: _responsavel.text.trim(),
        dataCriacao: _dataCriacao,
      );
    }

    if (!mounted) return;
    setState(() => _salvando = false);

    if (erro != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dataCriacao,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dataCriacao),
    );
    if (t == null) return;
    setState(() {
      _dataCriacao = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(
                  labelText: 'Descrição *',
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                validator: (v) => Validators.required(v, 'Descrição'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<Categoria>(
                value: _categoria,
                decoration: const InputDecoration(labelText: 'Categoria *', prefixIcon: Icon(Icons.category)),
                items: Categoria.values
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(children: [Text(c.icon), const SizedBox(width: 8), Text(c.label)]),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v!),
              ),
              const SizedBox(height: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prioridade *',
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<Prioridade>(
                    segments: Prioridade.values
                        .map((p) => ButtonSegment<Prioridade>(
                              value: p,
                              label: Text(p.label, style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                    selected: {_prioridade},
                    onSelectionChanged: (v) => setState(() => _prioridade = v.first),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _BairroField(
                controller: _bairro,
                bairrosExistentes: _bairrosExistentes,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _responsavel,
                decoration: const InputDecoration(labelText: 'Responsável *', prefixIcon: Icon(Icons.person)),
                validator: (v) => Validators.required(v, 'Responsável'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              if (_editando) ...[
                DropdownButtonFormField<Status>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status *', prefixIcon: Icon(Icons.flag)),
                  items: Status.values.map((s) => DropdownMenuItem(value: s, child: Text(s.label))).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 14),
              ],
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Data de Abertura'),
                subtitle: Text(AppDateUtils.formatDateTime(_dataCriacao)),
                trailing: const Icon(Icons.edit),
                onTap: _pickDateTime,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _salvando ? null : _salvar,
                icon: _salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
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

/// Campo de bairro com autocomplete. Usa um único TextEditingController
/// externo. O Autocomplete só sugere — quem manda na fonte é o controller.
class _BairroField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> bairrosExistentes;

  const _BairroField({required this.controller, required this.bairrosExistentes});

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (v) {
        if (v.text.isEmpty) return const Iterable<String>.empty();
        return bairrosExistentes
            .where((b) => b.toLowerCase().contains(v.text.toLowerCase()));
      },
      fieldViewBuilder: (ctx, ctrl, fn, onSub) {
        return TextFormField(
          controller: ctrl,
          focusNode: fn,
          decoration: const InputDecoration(
            labelText: 'Bairro *',
            prefixIcon: Icon(Icons.location_city),
          ),
          validator: (v) => Validators.required(v, 'Bairro'),
          textCapitalization: TextCapitalization.words,
        );
      },
      optionsViewBuilder: (ctx, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 320),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (_, i) {
                  final opt = options.elementAt(i);
                  return ListTile(
                    dense: true,
                    title: Text(opt),
                    onTap: () => onSelected(opt),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
