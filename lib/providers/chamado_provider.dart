import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/enums.dart';
import '../data/models/chamado.dart';
import '../data/repositories/chamado_repository.dart';

class ChamadoProvider extends ChangeNotifier {
  final _repo = ChamadoRepository();
  final _uuid = const Uuid();

  List<Chamado> _todos = [];
  String _busca = '';
  String? _filtroBairro;
  Status? _filtroStatus;
  bool _filtroCritico = false;

  bool get carregando => _carregando;
  bool _carregando = false;

  String? get erro => _erro;
  String? _erro;

  // --- Getters derivados ---

  List<Chamado> get chamadosFiltrados {
    var lista = [..._todos];

    if (_busca.isNotEmpty) {
      final q = _busca.toLowerCase();
      lista = lista.where((c) =>
        c.titulo.toLowerCase().contains(q) ||
        c.descricao.toLowerCase().contains(q) ||
        c.bairro.toLowerCase().contains(q)
      ).toList();
    }

    if (_filtroBairro != null) {
      lista = lista.where((c) => c.bairro == _filtroBairro).toList();
    }

    if (_filtroStatus != null) {
      lista = lista.where((c) => c.status == _filtroStatus).toList();
    }

    if (_filtroCritico) {
      lista = lista.where((c) => c.prioridade == Prioridade.critica).toList();
    }

    return lista;
  }

  List<String> get bairrosDisponiveis =>
      _todos.map((c) => c.bairro).toSet().toList()..sort();

  int get totalAbertos => _todos.where((c) => c.status == Status.aberto).length;
  int get totalEmAndamento => _todos.where((c) => c.status == Status.emAndamento).length;
  int get totalConcluidos => _todos.where((c) => c.status == Status.concluido).length;
  int get totalCriticos => _todos.where((c) => c.prioridade == Prioridade.critica).length;
  int get total => _todos.length;
  bool get alertaCriticos => totalCriticos > 5;

  String get busca => _busca;
  String? get filtroBairro => _filtroBairro;
  Status? get filtroStatus => _filtroStatus;
  bool get filtroCritico => _filtroCritico;

  // Dados para gráfico por categoria
  Map<Categoria, int> get porCategoria {
    final map = <Categoria, int>{};
    for (final c in _todos) {
      map[c.categoria] = (map[c.categoria] ?? 0) + 1;
    }
    return map;
  }

  // Ranking de bairros
  List<MapEntry<String, int>> get rankingBairros {
    final map = <String, int>{};
    for (final c in _todos) {
      map[c.bairro] = (map[c.bairro] ?? 0) + 1;
    }
    final entries = map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(5).toList();
  }

  Chamado? getChamadoById(String id) =>
      _todos.cast<Chamado?>().firstWhere((c) => c?.id == id, orElse: () => null);

  // --- Ações ---

  Future<void> carregar() async {
    _carregando = true;
    _erro = null;
    notifyListeners();
    try {
      _todos = await _repo.getAll();
    } catch (e) {
      _erro = 'Erro ao carregar chamados: $e';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  Future<String?> criar({
    required String titulo,
    required String descricao,
    required Categoria categoria,
    required Prioridade prioridade,
    required String bairro,
    required String responsavel,
    required DateTime dataCriacao,
  }) async {
    if (await _repo.tituloExiste(titulo)) {
      return 'Já existe um chamado com este título.';
    }
    final chamado = Chamado(
      id: _uuid.v4(),
      titulo: titulo.trim(),
      descricao: descricao.trim(),
      categoria: categoria,
      prioridade: prioridade,
      bairro: bairro.trim(),
      responsavel: responsavel.trim(),
      dataCriacao: dataCriacao,
      status: Status.aberto,
    );
    await _repo.insert(chamado);
    await carregar();
    return null;
  }

  Future<String?> editar(Chamado chamado) async {
    // Regra: chamados que ESTÃO concluídos no banco não podem ser editados.
    // O check é contra o estado original, não o novo (senão impede a transição p/ concluído).
    final original = _todos.firstWhere((c) => c.id == chamado.id);
    if (original.status == Status.concluido) {
      return 'Chamados concluídos não podem ser editados.';
    }
    if (await _repo.tituloExiste(chamado.titulo, ignorarId: chamado.id)) {
      return 'Já existe um chamado com este título.';
    }
    await _repo.update(chamado);
    await carregar();
    return null;
  }

  Future<void> alterarStatus(String id, Status novoStatus) async {
    final chamado = _todos.firstWhere((c) => c.id == id);
    await _repo.update(chamado.copyWith(status: novoStatus));
    await carregar();
  }

  Future<void> toggleFavorito(String id) async {
    final chamado = _todos.firstWhere((c) => c.id == id);
    await _repo.update(chamado.copyWith(favorito: !chamado.favorito));
    await carregar();
  }

  Future<void> excluir(String id) async {
    await _repo.delete(id);
    await carregar();
  }

  Future<void> limparTudo() async {
    await _repo.deleteAll();
    await carregar();
  }

  void setBusca(String value) {
    _busca = value;
    notifyListeners();
  }

  void setFiltroBairro(String? bairro) {
    _filtroBairro = bairro;
    notifyListeners();
  }

  void setFiltroStatus(Status? status) {
    _filtroStatus = status;
    notifyListeners();
  }

  void toggleFiltroCritico() {
    _filtroCritico = !_filtroCritico;
    notifyListeners();
  }

  void limparFiltros() {
    _busca = '';
    _filtroBairro = null;
    _filtroStatus = null;
    _filtroCritico = false;
    notifyListeners();
  }
}
