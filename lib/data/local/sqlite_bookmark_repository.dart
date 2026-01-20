import 'dart:async';

import 'package:open_stack/data/repositories/bookmark_repository.dart';
import 'package:open_stack/domain/entities/bookmark.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class SqliteBookmarkRepository implements BookmarkRepository {
  SqliteBookmarkRepository({String? dbName})
      : _dbFuture = _openDb(dbName ?? _defaultDbName);

  static const String _defaultDbName = 'open_stack_bookmarks.db';
  static const String _table = 'bookmarks';
  final Future<Database> _dbFuture;
  final StreamController<List<Bookmark>> _controller =
      StreamController<List<Bookmark>>.broadcast();

  @override
  Future<void> save(Bookmark b) async {
    final db = await _dbFuture;
    await db.insert(
      _table,
      _toMap(b),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _emitAll();
  }

  @override
  Future<void> remove(String id) async {
    final db = await _dbFuture;
    await db.delete(
      _table,
      where: 'id = ? OR repo_id = ? OR issue_id = ?',
      whereArgs: [id, id, id],
    );
    await _emitAll();
  }

  @override
  Stream<List<Bookmark>> watchAll() async* {
    yield await _loadAll();
    yield* _controller.stream;
  }

  @override
  Future<bool> isBookmarked(String issueId) async {
    final db = await _dbFuture;
    final rows = await db.query(
      _table,
      columns: const ['id'],
      where: 'id = ? OR repo_id = ? OR issue_id = ?',
      whereArgs: [issueId, issueId, issueId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<List<Bookmark>> _loadAll() async {
    final db = await _dbFuture;
    final rows = await db.query(
      _table,
      orderBy: 'saved_at DESC',
    );
    return rows.map(_fromMap).toList();
  }

  Future<void> _emitAll() async {
    if (_controller.isClosed) return;
    _controller.add(await _loadAll());
  }

  static Future<Database> _openDb(String name) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, name);
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table (
            id TEXT PRIMARY KEY,
            issue_id TEXT NOT NULL,
            repo_id TEXT NOT NULL,
            saved_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  static Map<String, Object?> _toMap(Bookmark b) {
    return {
      'id': b.id,
      'issue_id': b.issueId,
      'repo_id': b.repoId,
      'saved_at': b.savedAt.millisecondsSinceEpoch,
    };
  }

  static Bookmark _fromMap(Map<String, Object?> row) {
    return Bookmark(
      id: row['id'] as String,
      issueId: row['issue_id'] as String,
      repoId: row['repo_id'] as String,
      savedAt: DateTime.fromMillisecondsSinceEpoch(row['saved_at'] as int),
    );
  }
}
