enum Categoria {
  transito,
  iluminacao,
  saneamento,
  seguranca,
  limpezaUrbana,
  desastreNatural,
}

enum Prioridade { baixa, media, alta, critica }

enum Status { aberto, emAndamento, concluido }

extension CategoriaExt on Categoria {
  String get label {
    switch (this) {
      case Categoria.transito: return 'Trânsito';
      case Categoria.iluminacao: return 'Iluminação';
      case Categoria.saneamento: return 'Saneamento';
      case Categoria.seguranca: return 'Segurança';
      case Categoria.limpezaUrbana: return 'Limpeza Urbana';
      case Categoria.desastreNatural: return 'Desastre Natural';
    }
  }

  String get icon {
    switch (this) {
      case Categoria.transito: return '🚦';
      case Categoria.iluminacao: return '💡';
      case Categoria.saneamento: return '💧';
      case Categoria.seguranca: return '🚨';
      case Categoria.limpezaUrbana: return '🗑️';
      case Categoria.desastreNatural: return '🌊';
    }
  }
}

extension PrioridadeExt on Prioridade {
  String get label {
    switch (this) {
      case Prioridade.baixa: return 'Baixa';
      case Prioridade.media: return 'Média';
      case Prioridade.alta: return 'Alta';
      case Prioridade.critica: return 'Crítica';
    }
  }

  int get ordem => index;
}

extension StatusExt on Status {
  String get label {
    switch (this) {
      case Status.aberto: return 'Aberto';
      case Status.emAndamento: return 'Em Andamento';
      case Status.concluido: return 'Concluído';
    }
  }
}
