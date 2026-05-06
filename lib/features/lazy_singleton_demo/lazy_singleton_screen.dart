import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../core/widgets/code_block.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_header.dart';
import 'analytics_service.dart';

class LazySingletonScreen extends StatefulWidget {
  const LazySingletonScreen({super.key});

  @override
  State<LazySingletonScreen> createState() => _LazySingletonScreenState();
}

class _LazySingletonScreenState extends State<LazySingletonScreen> {
  static const _color = Color(0xFF0891B2);
  AnalyticsService? _service;
  int _accessCount = 0;
  final _eventCtrl = TextEditingController();

  void _access() {
    setState(() {
      _service = getIt<AnalyticsService>();
      _accessCount++;
    });
  }

  void _track() {
    final msg = _eventCtrl.text.trim();
    if (msg.isEmpty) return;
    _service?.track(msg);
    _eventCtrl.clear();
    setState(() {});
  }

  @override
  void dispose() {
    _eventCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@lazySingleton'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'What is @lazySingleton?',
            body:
                'Like @singleton but the instance is created only when '
                'first requested — not at app startup. Saves memory and '
                'startup time for heavy services that may not be needed immediately.',
            color: _color,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'ANNOTATION', icon: Icons.code),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'analytics_service.dart',
            code: '''@lazySingleton          // ← not created at startup
class AnalyticsService {
  final DateTime initializedAt = DateTime.now();
  final List<String> _events = [];

  void track(String event) { _events.add(event); }
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'injection.config.dart  (generated)',
            code: '''// Registered but NOT instantiated yet:
gh.lazySingleton<AnalyticsService>(() => AnalyticsService());
// ↑ Constructor runs only on first getIt<AnalyticsService>() call''',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'LIVE DEMO', icon: Icons.play_arrow),
          const SizedBox(height: 8),
          _buildStatusCard(context),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _access,
            icon: const Icon(Icons.bolt),
            label: Text(_service == null
                ? 'Access Service (trigger init)'
                : 'Access Again (×$_accessCount)'),
            style: FilledButton.styleFrom(backgroundColor: _color),
          ),
          if (_service != null) ...[
            const SizedBox(height: 16),
            const SectionHeader(title: 'TRACK EVENTS', icon: Icons.track_changes),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _eventCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. user_signed_in',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _track(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _track,
                  style: FilledButton.styleFrom(backgroundColor: _color),
                  child: const Text('Track'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_service!.events.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('No events tracked yet.',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _service!.events.reversed
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            e,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Color(0xFF7DD3FC),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 12),
            InfoCard(
              title: '✓ Same instance across $_accessCount access(es)',
              body:
                  'Initialized at ${_fmt(_service!.initializedAt)}. '
                  'Every subsequent getIt<AnalyticsService>() call returns '
                  'this same instance — your events persist.',
              color: _color,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    final initialized = _service != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: initialized ? _color.withAlpha(15) : Colors.grey.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: initialized ? _color.withAlpha(60) : Colors.grey.withAlpha(60),
        ),
      ),
      child: Row(
        children: [
          Icon(
            initialized ? Icons.check_circle : Icons.radio_button_unchecked,
            color: initialized ? _color : Colors.grey,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                initialized ? 'INITIALIZED' : 'NOT YET INITIALIZED',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: initialized ? _color : Colors.grey,
                  letterSpacing: 0.5,
                ),
              ),
              if (initialized)
                Text(
                  'Initialized at ${_fmt(_service!.initializedAt)}',
                  style: const TextStyle(fontSize: 12),
                )
              else
                const Text(
                  'getIt<AnalyticsService>() not called yet',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
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
