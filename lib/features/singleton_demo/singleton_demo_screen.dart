import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../core/widgets/code_block.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_header.dart';
import 'app_state_service.dart';

class SingletonDemoScreen extends StatefulWidget {
  const SingletonDemoScreen({super.key});

  @override
  State<SingletonDemoScreen> createState() => _SingletonDemoScreenState();
}

class _SingletonDemoScreenState extends State<SingletonDemoScreen> {
  static const _color = Color(0xFF16A34A);
  late AppStateService _service;
  int _fetchCount = 0;

  @override
  void initState() {
    super.initState();
    _service = getIt<AppStateService>();
    _fetchCount = 1;
  }

  void _refetch() {
    final fetched = getIt<AppStateService>();
    setState(() {
      _service = fetched;
      _fetchCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@singleton'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'What is @singleton?',
            body:
                'Created once when first requested (or at startup), then reused '
                'forever. Every getIt<T>() call returns the exact same object. '
                'Ideal for app-wide state, configs, and services.',
            color: _color,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'ANNOTATION', icon: Icons.code),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'app_state_service.dart',
            code: '''@singleton
class AppStateService {
  final String instanceId;
  final DateTime createdAt;
  int _sessionCount = 0;

  AppStateService()
    : instanceId = generateId(),
      createdAt = DateTime.now();

  int get sessionCount => _sessionCount;
  void increment() => _sessionCount++;
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'injection.config.dart  (generated)',
            code: '''// Registered once, same instance returned every time:
gh.singleton<AppStateService>(() => AppStateService());''',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'LIVE DEMO', icon: Icons.play_arrow),
          const SizedBox(height: 8),
          _buildInstanceCard(context),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => setState(() => _service.increment()),
                  icon: const Icon(Icons.add),
                  label: const Text('Increment Counter'),
                  style: FilledButton.styleFrom(backgroundColor: _color),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _refetch,
                  icon: const Icon(Icons.refresh),
                  label: Text('Re-fetch (×$_fetchCount)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: _fetchCount > 1
                ? '✓ Same instance every time'
                : 'Try "Re-fetch" — you\'ll always get the same object',
            body: _fetchCount > 1
                ? 'You\'ve called getIt<AppStateService>() $_fetchCount times. '
                    'The instance ID, creation time, and counter never change — '
                    'it\'s always the same object in memory.'
                : 'Press "Re-fetch" to call getIt<AppStateService>() again. '
                    'The instance ID and counter will stay identical.',
            color: _color,
          ),
        ],
      ),
    );
  }

  Widget _buildInstanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withAlpha(50)),
      ),
      child: Column(
        children: [
          _Row('Instance ID', _service.instanceId, monospace: true),
          const Divider(height: 16),
          _Row('Created at', _fmt(_service.createdAt)),
          const Divider(height: 16),
          _Row(
            'Session counter',
            '${_service.sessionCount}',
            highlight: true,
            color: _color,
          ),
          const Divider(height: 16),
          _Row('getIt<> calls made', '$_fetchCount'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final bool highlight;
  final Color? color;

  const _Row(
    this.label,
    this.value, {
    this.monospace = false,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150))),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: highlight ? 20 : 13,
            fontFamily: monospace ? 'monospace' : null,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
            color: color ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

String _fmt(DateTime dt) =>
    '${dt.hour.toString().padLeft(2, '0')}:'
    '${dt.minute.toString().padLeft(2, '0')}:'
    '${dt.second.toString().padLeft(2, '0')}.'
    '${dt.millisecond.toString().padLeft(3, '0')}';
