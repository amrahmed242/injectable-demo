import 'package:injectable/injectable.dart';

@lazySingleton
class DatabaseService {
  final String dbPath;
  final int schemaVersion;
  final DateTime connectedAt;

  DatabaseService._({
    required this.dbPath,
    required this.schemaVersion,
    required this.connectedAt,
  });

  @factoryMethod
  static Future<DatabaseService> init() async {
    // Simulate opening a database, running migrations, etc.
    await Future.delayed(const Duration(seconds: 2));
    return DatabaseService._(
      dbPath: '/data/user/app.db',
      schemaVersion: 5,
      connectedAt: DateTime.now(),
    );
  }

  Future<List<Map<String, dynamic>>> query(String table) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return switch (table) {
      'users' => [
          {'id': 1, 'name': 'Alice', 'email': 'alice@example.com'},
          {'id': 2, 'name': 'Bob', 'email': 'bob@example.com'},
          {'id': 3, 'name': 'Carol', 'email': 'carol@example.com'},
        ],
      'posts' => [
          {'id': 1, 'title': 'Hello World', 'authorId': 1},
          {'id': 2, 'title': 'DI in Flutter', 'authorId': 1},
        ],
      _ => [
          {'id': 1, 'value': 'Row 1 from $table'},
          {'id': 2, 'value': 'Row 2 from $table'},
        ],
    };
  }

  Future<void> dispose() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
