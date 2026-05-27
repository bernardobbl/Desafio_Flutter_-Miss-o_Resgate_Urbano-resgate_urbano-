import '../../core/constants/enums.dart';

class Chamado {
  final String id;
  final String titulo;
  final String descricao;
  final Categoria categoria;
  final Prioridade prioridade;
  final String bairro;
  final String responsavel;
  final DateTime dataCriacao;
  final Status status;
  final bool favorito;

  const Chamado({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.dataCriacao,
    required this.status,
    this.favorito = false,
  });

  Chamado copyWith({
    String? id,
    String? titulo,
    String? descricao,
    Categoria? categoria,
    Prioridade? prioridade,
    String? bairro,
    String? responsavel,
    DateTime? dataCriacao,
    Status? status,
    bool? favorito,
  }) {
    return Chamado(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prioridade: prioridade ?? this.prioridade,
      bairro: bairro ?? this.bairro,
      responsavel: responsavel ?? this.responsavel,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      status: status ?? this.status,
      favorito: favorito ?? this.favorito,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'categoria': categoria.index,
        'prioridade': prioridade.index,
        'bairro': bairro,
        'responsavel': responsavel,
        'data_criacao': dataCriacao.millisecondsSinceEpoch,
        'status': status.index,
        'favorito': favorito ? 1 : 0,
      };

  factory Chamado.fromMap(Map<String, dynamic> map) => Chamado(
        id: map['id'] as String,
        titulo: map['titulo'] as String,
        descricao: map['descricao'] as String,
        categoria: Categoria.values[map['categoria'] as int],
        prioridade: Prioridade.values[map['prioridade'] as int],
        bairro: map['bairro'] as String,
        responsavel: map['responsavel'] as String,
        dataCriacao: DateTime.fromMillisecondsSinceEpoch(map['data_criacao'] as int),
        status: Status.values[map['status'] as int],
        favorito: (map['favorito'] as int) == 1,
      );
}
