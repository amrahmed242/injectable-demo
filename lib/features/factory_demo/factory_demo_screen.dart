import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../core/widgets/code_block.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_header.dart';
import 'counter_service.dart';

class FactoryDemoScreen extends StatefulWidget {
  const FactoryDemoScreen({super.key});

  @override
  State<FactoryDemoScreen> createState() => _FactoryDemoScreenState();
}

class _FactoryDemoScreenState extends State<FactoryDemoScreen> {
  static const _color = Color(0xFF2563EB);
  final _instances = <CounterService>[];

  void _createInstance() {
    setState(() => _instances.add(getIt<CounterService>()));
  }

  void _removeAll() => setState(() => _instances.clear());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@injectable — Factory'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'What is @injectable?',
            body:
                'Registers a factory: get_it calls the constructor each time '
                'you request the type. Every call returns a brand-new, '
                'independent instance — no shared state.',
            color: _color,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'ANNOTATION', icon: Icons.code),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'counter_service.dart',
            code: '''@injectable           // ← that\'s it
class CounterService {
  final String instanceId = _randomId();
  int _count = 0;

  int get count => _count;
  void increment() => _count++;
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'injection.config.dart  (generated)',
            code: '''// build_runner produces this automatically:
gh.factory<CounterService>(() => CounterService());
// ↑ a new CounterService() on every getIt<CounterService>() call''',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'LIVE DEMO', icon: Icons.play_arrow),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _createInstance,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Instance'),
                  style: FilledButton.styleFrom(backgroundColor: _color),
                ),
              ),
              if (_instances.isNotEmpty) ...[
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _removeAll,
                  child: const Text('Clear'),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (_instances.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _color.withAlpha(10),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _color.withAlpha(30)),
              ),
              child: Text(
                'Press "Create Instance" to call\ngetIt<CounterService>()',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ),
          ..._instances.asMap().entries.map(
                (e) => _InstanceTile(
                  index: e.key,
                  service: e.value,
                  color: _color,
                  onChanged: () => setState(() {}),
                ),
              ),
          if (_instances.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: InfoCard(
                title: '✓ All ${_instances.length} instances are independent',
                body:
                    'Each has a unique ID and its own counter. Modifying one '
                    'does not affect the others — that\'s factory registration.',
                color: _color,
              ),
            ),
        ],
      ),
    );
  }
}

class _InstanceTile extends StatelessWidget {
  final int index;
  final CounterService service;
  final Color color;
  final VoidCallback onChanged;

  const _InstanceTile({
    required this.index,
    required this.service,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instance #${index + 1}',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12, color: color),
                ),
                Text(
                  'ID: ${service.instanceId}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.remove, size: 18),
              onPressed: () {
                service.decrement();
                onChanged();
              },
              style: IconButton.styleFrom(
                backgroundColor: color.withAlpha(15),
                foregroundColor: color,
                padding: const EdgeInsets.all(6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${service.count}',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 18, color: color),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 18),
              onPressed: () {
                service.increment();
                onChanged();
              },
              style: IconButton.styleFrom(
                backgroundColor: color.withAlpha(15),
                foregroundColor: color,
                padding: const EdgeInsets.all(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
