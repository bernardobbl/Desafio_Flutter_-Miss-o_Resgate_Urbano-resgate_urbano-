import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _db;

  DatabaseHelper._();
  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resgate_urbano.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chamados (
            id TEXT PRIMARY KEY,
            titulo TEXT UNIQUE NOT NULL,
            descricao TEXT NOT NULL,
            categoria INTEGER NOT NULL,
            prioridade INTEGER NOT NULL,
            bairro TEXT NOT NULL,
            responsavel TEXT NOT NULL,
            data_criacao INTEGER NOT NULL,
            status INTEGER NOT NULL,
            favorito INTEGER DEFAULT 0
          )
        ''');
        await db.execute('CREATE INDEX idx_prioridade ON chamados(prioridade DESC)');
        await db.execute('CREATE INDEX idx_status ON chamados(status)');
      },
    );
  }
}
