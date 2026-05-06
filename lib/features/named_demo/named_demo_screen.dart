import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../core/widgets/code_block.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_header.dart';
import 'logger.dart';

class NamedDemoScreen extends StatefulWidget {
  const NamedDemoScreen({super.key});

  @override
  State<NamedDemoScreen> createState() => _NamedDemoScreenState();
}

class _NamedDemoScreenState extends State<NamedDemoScreen>
    with SingleTickerProviderStateMixin {
  static const _color = Color(0xFF7C3AED);
  late TabController _tabs;
  final _msgCtrl = TextEditingController();

  Logger get _console => getIt<Logger>(instanceName: 'console');
  Logger get _remote => getIt<Logger>(instanceName: 'remote');

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Logger get _active => _tabs.index == 0 ? _console : _remote;

  void _log() {
    final msg = _msgCtrl.text.trim();
    if (msg.isEmpty) return;
    _active.log(msg);
    _msgCtrl.clear();
    setState(() {});
  }

  void _clear() {
    _active.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@Named — Named Registrations'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: '${_console.icon} ConsoleLogger'),
            Tab(text: '${_remote.icon} RemoteLogger'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'What is @Named?',
            body:
                'Register multiple implementations of the same interface under '
                'different string keys. Inject by name where you need a specific '
                'implementation — keeps code polymorphic and testable.',
            color: _color,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'ANNOTATION', icon: Icons.code),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'logger implementations',
            code: '''abstract class Logger { void log(String msg); }

@Named(\'console\')
@Injectable(as: Logger)
class ConsoleLogger implements Logger {
  void log(String msg) => print(\'[stdout] \$msg\');
}

@Named(\'remote\')
@Injectable(as: Logger)
class RemoteLogger implements Logger {
  void log(String msg) => http.post(\'/logs\', body: msg);
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'usage — inject by name',
            code: '''// In another service\'s constructor:
class ReportService {
  ReportService(
    @Named(\'console\') this.devLogger,
    @Named(\'remote\')  this.prodLogger,
  );
}

// Or get directly from the container:
final logger = getIt<Logger>(instanceName: \'console\');''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'injection.config.dart  (generated)',
            code: '''gh.factory<Logger>(() => ConsoleLogger(), instanceName: \'console\');
gh.factory<Logger>(() => RemoteLogger(),  instanceName: \'remote\');''',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'LIVE DEMO', icon: Icons.play_arrow),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _color.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _color.withAlpha(50)),
            ),
            child: Row(
              children: [
                const Text('Active logger: ', style: TextStyle(fontSize: 13)),
                Text(
                  '${_active.icon} ${_active.name}',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13, color: _color),
                ),
                const Spacer(),
                Text(
                  'instanceName: \'${_tabs.index == 0 ? 'console' : 'remote'}\'',
                  style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter a log message…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _log(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _log,
                style: FilledButton.styleFrom(backgroundColor: _color),
                child: const Text('Log'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: _active.logs.isEmpty ? null : _clear,
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_active.logs.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'No logs yet for ${_active.name}',
                style:
                    const TextStyle(color: Colors.grey, fontFamily: 'monospace'),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _active.logs.reversed
                    .map(
                      (log) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: _tabs.index == 0
                                ? const Color(0xFF86EFAC)
                                : const Color(0xFF93C5FD),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(height: 12),
          const InfoCard(
            title: '↑ Switch tabs to compare',
            body:
                'Each tab fetches a different Logger implementation by name. '
                'Both are factories so each tab\'s logs are tracked separately. '
                'The caller never knows the concrete class — only the Logger interface.',
            color: _color,
          ),
        ],
      ),
    );
  }
}
