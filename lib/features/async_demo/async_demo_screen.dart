import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../core/widgets/code_block.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_header.dart';
import 'database_service.dart';

class AsyncDemoScreen extends StatefulWidget {
  const AsyncDemoScreen({super.key});

  @override
  State<AsyncDemoScreen> createState() => _AsyncDemoScreenState();
}

class _AsyncDemoScreenState extends State<AsyncDemoScreen> {
  static const _color = Color(0xFF4338CA);

  DatabaseService? _db;
  bool _connecting = false;
  String? _error;
  int _accessCount = 0;

  String? _queryTable;
  List<Map<String, dynamic>>? _queryResult;
  bool _querying = false;

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });
    try {
      final db = await getIt.getAsync<DatabaseService>();
      setState(() {
        _db = db;
        _connecting = false;
        _accessCount++;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _connecting = false;
      });
    }
  }

  Future<void> _reconnect() async {
    // Already ready — getAsync resolves immediately
    final db = await getIt.getAsync<DatabaseService>();
    setState(() {
      _db = db;
      _accessCount++;
    });
  }

  Future<void> _query(String table) async {
    if (_db == null) return;
    setState(() {
      _querying = true;
      _queryTable = table;
    });
    final rows = await _db!.query(table);
    setState(() {
      _queryResult = rows;
      _querying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@factoryMethod (async)'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'What is async initialization?',
            body:
                'Mark a static method with @factoryMethod and return a Future<T>. '
                'Injectable registers it as an async factory/singleton. '
                'Call getIt.getAsync<T>() to await the initialization. '
                'Perfect for database connections, file I/O, and remote configs.',
            color: _color,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'ANNOTATION', icon: Icons.code),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'database_service.dart',
            code: '''@lazySingleton
class DatabaseService {
  final String dbPath;
  final int schemaVersion;

  DatabaseService._({required this.dbPath, ...});

  @factoryMethod                        // ← injectable calls this
  static Future<DatabaseService> init() async {
    await Future.delayed(Duration(seconds: 2)); // open DB, run migrations
    return DatabaseService._(
      dbPath: \'/data/app.db\',
      schemaVersion: 5,
    );
  }

  Future<List<Map>> query(String table) async { ... }
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'injection.config.dart  (generated)',
            code: '''// Lazy: registered now, init() called on first access
gh.lazySingletonAsync<DatabaseService>(
  () => DatabaseService.init(),
);

// Resolve it:
final db = await getIt.getAsync<DatabaseService>();
// or in main: await getIt.allReady();''',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'LIVE DEMO', icon: Icons.play_arrow),
          const SizedBox(height: 8),
          _buildStatusCard(context),
          const SizedBox(height: 10),
          if (_db == null) ...[
            FilledButton.icon(
              onPressed: _connecting ? null : _connect,
              icon: _connecting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.storage),
              label: Text(_connecting
                  ? 'Connecting… (2s simulated delay)'
                  : 'Connect to Database'),
              style: FilledButton.styleFrom(backgroundColor: _color),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _reconnect,
                    icon: const Icon(Icons.refresh),
                    label: Text('Re-fetch (×$_accessCount)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SectionHeader(title: 'QUERY DATABASE', icon: Icons.search),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['users', 'posts', 'settings'].map((table) {
                return ActionChip(
                  label: Text(table),
                  avatar: const Icon(Icons.table_chart_outlined, size: 16),
                  onPressed: _querying ? null : () => _query(table),
                  backgroundColor: _queryTable == table
                      ? _color.withAlpha(30)
                      : null,
                );
              }).toList(),
            ),
            if (_querying)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_queryResult != null) ...[
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                      child: Text(
                        'SELECT * FROM $_queryTable  →  ${_queryResult!.length} rows',
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Color(0xFF6C8EBF)),
                      ),
                    ),
                    const Divider(color: Color(0xFF21262D)),
                    ..._queryResult!.map(
                      (row) => Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 4, 12, 4),
                        child: Text(
                          row.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join('  |  '),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Color(0xFFE6EDF3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            InfoCard(
              title: '✓ Same instance across $_accessCount access(es)',
              body:
                  'Connected at ${_fmt(_db!.connectedAt)}. '
                  '"Re-fetch" calls getIt.getAsync<DatabaseService>() again — '
                  'it resolves instantly since the lazy singleton is already ready.',
              color: _color,
            ),
          ],
          if (_error != null)
            InfoCard(
              title: 'Error',
              body: _error!,
              color: Colors.red,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _db != null
            ? _color.withAlpha(15)
            : _connecting
                ? Colors.orange.withAlpha(15)
                : Colors.grey.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _db != null
              ? _color.withAlpha(60)
              : _connecting
                  ? Colors.orange.withAlpha(60)
                  : Colors.grey.withAlpha(40),
        ),
      ),
      child: Row(
        children: [
          _connecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(
                  _db != null ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: _db != null ? _color : Colors.grey,
                ),
          const SizedBox(width: 12),
          if (_db != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CONNECTED',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: _color,
                        letterSpacing: 0.5)),
                Text('${_db!.dbPath}  ·  schema v${_db!.schemaVersion}',
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              ],
            )
          else if (_connecting)
            const Text('Initializing DatabaseService…',
                style: TextStyle(fontSize: 13, color: Colors.orange))
          else
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NOT CONNECTED',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Colors.grey,
                        letterSpacing: 0.5)),
                Text('getIt.getAsync<DatabaseService>() not called yet',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
        ],
      ),
    );
  }
}

String _fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:'
    '${dt.minute.toString().padLeft(2, '0')}:'
    '${dt.second.toString().padLeft(2, '0')}.'
    '${dt.millisecond.toString().padLeft(3, '0')}';
