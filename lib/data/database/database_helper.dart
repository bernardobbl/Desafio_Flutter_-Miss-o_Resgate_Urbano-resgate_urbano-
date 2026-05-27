import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _db;
  static bool _initialized = false;

  DatabaseHelper._();
  factory DatabaseHelper() => _instance;

  /// Inicializa o factory correto para cada plataforma.
  /// - Web: sqflite_common_ffi_web (SQLite compilado para WASM)
  /// - macOS/Windows/Linux: sqflite_common_ffi (SQLite nativo via FFI)
  /// - Android/iOS: sqflite padrão
  static void _initFactory() {
    if (_initialized) return;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _initialized = true;
  }

  Future<Database> get database async {
    _initFactory();
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = kIsWeb ? 'resgate_urbano.db' : join(await getDatabasesPath(), 'resgate_urbano.db');

    return databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
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
      ),
    );
  }
}
