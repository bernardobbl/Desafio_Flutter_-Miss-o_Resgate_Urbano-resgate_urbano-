import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/chamado.dart';

class ChamadoRepository {
  final DatabaseHelper _helper = DatabaseHelper();

  Future<Database> get _db async => _helper.database;

  Future<List<Chamado>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      'chamados',
      orderBy: 'prioridade DESC, data_criacao DESC',
    );
    return rows.map(Chamado.fromMap).toList();
  }

  Future<Chamado?> getById(String id) async {
    final db = await _db;
    final rows = await db.query('chamados', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Chamado.fromMap(rows.first);
  }

  Future<bool> tituloExiste(String titulo, {String? ignorarId}) async {
    final db = await _db;
    final rows = await db.query(
      'chamados',
      where: ignorarId != null ? 'titulo = ? AND id != ?' : 'titulo = ?',
      whereArgs: ignorarId != null ? [titulo.trim(), ignorarId] : [titulo.trim()],
    );
    return rows.isNotEmpty;
  }

  Future<void> insert(Chamado chamado) async {
    final db = await _db;
    await db.insert('chamados', chamado.toMap(), conflictAlgorithm: ConflictAlgorithm.fail);
  }

  Future<void> update(Chamado chamado) async {
    final db = await _db;
    await db.update('chamados', chamado.toMap(), where: 'id = ?', whereArgs: [chamado.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db;
    await db.delete('chamados', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete('chamados');
  }
}
