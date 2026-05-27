import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/enums.dart';
import 'models/chamado.dart';
import 'repositories/chamado_repository.dart';

class SeedData {
  static const _key = 'seed_done_v1';

  static Future<void> inicializarSeNecessario() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_key) == true) return;

    final repo = ChamadoRepository();
    final uuid = const Uuid();
    final agora = DateTime.now();

    final chamados = [
      Chamado(id: uuid.v4(), titulo: 'Buraco na Av. Principal', descricao: 'Buraco profundo causando risco a motoristas e pedestres.', categoria: Categoria.transito, prioridade: Prioridade.alta, bairro: 'Centro', responsavel: 'João Silva', dataCriacao: agora.subtract(const Duration(hours: 5)), status: Status.aberto),
      Chamado(id: uuid.v4(), titulo: 'Poste apagado na Rua das Flores', descricao: 'Poste sem iluminação há 3 dias, área escura à noite.', categoria: Categoria.iluminacao, prioridade: Prioridade.media, bairro: 'Jardim Novo', responsavel: 'Maria Santos', dataCriacao: agora.subtract(const Duration(days: 2)), status: Status.emAndamento),
      Chamado(id: uuid.v4(), titulo: 'Vazamento de esgoto', descricao: 'Esgoto transbordando na calçada, risco sanitário.', categoria: Categoria.saneamento, prioridade: Prioridade.critica, bairro: 'Vila Industrial', responsavel: 'Carlos Pereira', dataCriacao: agora.subtract(const Duration(hours: 1)), status: Status.aberto),
      Chamado(id: uuid.v4(), titulo: 'Árvore caída na pista', descricao: 'Árvore de grande porte bloqueando metade da via.', categoria: Categoria.desastreNatural, prioridade: Prioridade.critica, bairro: 'Beira-Rio', responsavel: 'Ana Costa', dataCriacao: agora.subtract(const Duration(minutes: 30)), status: Status.emAndamento),
      Chamado(id: uuid.v4(), titulo: 'Lixo acumulado no beco', descricao: 'Lixo há mais de uma semana sem coleta, gerando mau cheiro.', categoria: Categoria.limpezaUrbana, prioridade: Prioridade.baixa, bairro: 'Centro', responsavel: 'Pedro Lima', dataCriacao: agora.subtract(const Duration(days: 7)), status: Status.aberto),
      Chamado(id: uuid.v4(), titulo: 'Semáforo com defeito', descricao: 'Semáforo piscando amarelo continuamente na cruzamento movimentado.', categoria: Categoria.transito, prioridade: Prioridade.alta, bairro: 'Centro', responsavel: 'Lucia Fernandes', dataCriacao: agora.subtract(const Duration(hours: 3)), status: Status.aberto),
      Chamado(id: uuid.v4(), titulo: 'Enchente na Rua Baixa', descricao: 'Rua alagada após chuva forte, vários veículos ilhados.', categoria: Categoria.desastreNatural, prioridade: Prioridade.critica, bairro: 'Beira-Rio', responsavel: 'Roberto Alves', dataCriacao: agora.subtract(const Duration(hours: 2)), status: Status.emAndamento),
      Chamado(id: uuid.v4(), titulo: 'Vandalismo em praça pública', descricao: 'Bancos e equipamentos de ginástica danificados.', categoria: Categoria.seguranca, prioridade: Prioridade.media, bairro: 'Jardim Novo', responsavel: 'Fernanda Castro', dataCriacao: agora.subtract(const Duration(days: 1)), status: Status.aberto),
      Chamado(id: uuid.v4(), titulo: 'Calçada quebrada', descricao: 'Calçada em péssimo estado dificultando locomoção de idosos.', categoria: Categoria.transito, prioridade: Prioridade.baixa, bairro: 'Vila Industrial', responsavel: 'Marcos Souza', dataCriacao: agora.subtract(const Duration(days: 5)), status: Status.concluido),
      Chamado(id: uuid.v4(), titulo: 'Poda de árvore urgente', descricao: 'Galho ameaçando cair sobre fiação elétrica.', categoria: Categoria.desastreNatural, prioridade: Prioridade.alta, bairro: 'Alto da Serra', responsavel: 'Claudia Ramos', dataCriacao: agora.subtract(const Duration(hours: 8)), status: Status.aberto),
      Chamado(id: uuid.v4(), titulo: 'Falta d\'água no bairro', descricao: 'Sem abastecimento há 24h em toda a região.', categoria: Categoria.saneamento, prioridade: Prioridade.alta, bairro: 'Alto da Serra', responsavel: 'Tiago Moreira', dataCriacao: agora.subtract(const Duration(hours: 20)), status: Status.emAndamento),
      Chamado(id: uuid.v4(), titulo: 'Iluminação pública danificada', descricao: 'Vários postes sem funcionar na avenida principal.', categoria: Categoria.iluminacao, prioridade: Prioridade.media, bairro: 'Centro', responsavel: 'Sandra Lima', dataCriacao: agora.subtract(const Duration(days: 3)), status: Status.concluido),
    ];

    for (final c in chamados) {
      try {
        await repo.insert(c);
      } catch (e) {
        debugPrint('Seed: erro ao inserir ${c.titulo}: $e');
      }
    }

    await prefs.setBool(_key, true);
  }
}
