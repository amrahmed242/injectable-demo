import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../core/widgets/code_block.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_header.dart';
import 'http_service.dart';

class ModuleDemoScreen extends StatefulWidget {
  const ModuleDemoScreen({super.key});

  @override
  State<ModuleDemoScreen> createState() => _ModuleDemoScreenState();
}

class _ModuleDemoScreenState extends State<ModuleDemoScreen> {
  static const _color = Color(0xFFDC2626);
  final _pathCtrl = TextEditingController(text: '/users/1');
  String? _response;
  bool _loading = false;

  late final HttpService _http = getIt<HttpService>();

  Future<void> _request() async {
    final path = _pathCtrl.text.trim();
    if (path.isEmpty) return;
    setState(() {
      _loading = true;
      _response = null;
    });
    final result = await _http.get(path);
    setState(() {
      _response = result;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _pathCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@module — Modules'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'What is @module?',
            body:
                'Some classes come from third-party packages — you can\'t add '
                '@injectable to them. @module lets you register these by '
                'writing a provider class. Injectable generates the registration '
                'call from your getter or method.',
            color: _color,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'ANNOTATION', icon: Icons.code),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'http_service.dart  (third-party — no annotation)',
            code: '''// Cannot modify this class (from a package):
class HttpService {
  final String baseUrl;
  final Duration timeout;

  const HttpService({required this.baseUrl, this.timeout = ...});

  Future<String> get(String path) async { ... }
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'app_module.dart  (your code)',
            code: '''@module                         // ← marks this as a DI module
abstract class AppModule {
  @singleton                      // ← lifecycle annotation still works
  HttpService get httpService => const HttpService(
    baseUrl: \'https://api.myapp.com\',
    timeout: Duration(seconds: 15),
  );
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'injection.config.dart  (generated)',
            code: '''final appModule = AppModule();
gh.singleton<HttpService>(() => appModule.httpService);
// ↑ injectable instantiates AppModule and calls your getter''',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'LIVE DEMO', icon: Icons.play_arrow),
          const SizedBox(height: 8),
          _buildConfigCard(context),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pathCtrl,
                  decoration: InputDecoration(
                    labelText: 'Path',
                    prefixText: _http.baseUrl,
                    prefixStyle:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _loading ? null : _request,
                style: FilledButton.styleFrom(backgroundColor: _color),
                child: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('GET'),
              ),
            ],
          ),
          if (_response != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _response!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: Color(0xFF86EFAC),
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          const InfoCard(
            title: '✓ HttpService has no @injectable annotation',
            body:
                'The @module class acts as a factory. Injectable calls your '
                'getter to produce the instance, then registers it with the '
                'lifecycle you specify (@singleton here). Works for any class — '
                'platform types, http clients, shared preferences, etc.',
            color: _color,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withAlpha(50)),
      ),
      child: Column(
        children: [
          _Row('Registered class', 'HttpService (via AppModule)'),
          const Divider(height: 14),
          _Row('baseUrl', _http.baseUrl, mono: true),
          const Divider(height: 14),
          _Row('timeout', '${_http.timeout.inSeconds}s'),
          const Divider(height: 14),
          _Row('defaultHeaders', _http.defaultHeaders.keys.join(', ')),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _Row(this.label, this.value, {this.mono = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color:
                    Theme.of(context).colorScheme.onSurface.withAlpha(150))),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontFamily: mono ? 'monospace' : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
