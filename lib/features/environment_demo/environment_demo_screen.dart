import 'package:flutter/material.dart';

import '../../di/injection.dart';
import '../../core/widgets/code_block.dart';
import '../../core/widgets/info_card.dart';
import '../../core/widgets/section_header.dart';
import 'api_client.dart';
import 'prod_api_client.dart';

class EnvironmentDemoScreen extends StatefulWidget {
  const EnvironmentDemoScreen({super.key});

  @override
  State<EnvironmentDemoScreen> createState() => _EnvironmentDemoScreenState();
}

class _EnvironmentDemoScreenState extends State<EnvironmentDemoScreen> {
  static const _color = Color(0xFFD97706);

  // App started with Environment.dev — only DevApiClient is registered.
  final ApiClient _devClient = getIt<ApiClient>();
  // Show prod side-by-side via direct instantiation for comparison.
  final ApiClient _prodClient = ProdApiClient();

  Map<String, dynamic>? _devResult;
  Map<String, dynamic>? _prodResult;
  bool _devLoading = false;
  bool _prodLoading = false;

  Future<void> _fetchDev() async {
    setState(() => _devLoading = true);
    final result = await _devClient.fetchUser('usr_42');
    setState(() {
      _devResult = result;
      _devLoading = false;
    });
  }

  Future<void> _fetchProd() async {
    setState(() => _prodLoading = true);
    final result = await _prodClient.fetchUser('usr_42');
    setState(() {
      _prodResult = result;
      _prodLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('@dev / @prod — Environments'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const InfoCard(
            title: 'What is environment scoping?',
            body:
                'Injectable lets you bind an annotation to an environment string. '
                'When you call configureDependencies(env: "dev"), only @dev '
                'classes are registered. Switch to "prod" and only @prod classes '
                'are registered. Same interface, swapped implementation.',
            color: _color,
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'ANNOTATION', icon: Icons.code),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'api_client implementations',
            code: '''abstract class ApiClient {
  Future<Map<String, dynamic>> fetchUser(String id);
}

@dev
@Injectable(as: ApiClient)        // registered only in dev
class DevApiClient implements ApiClient {
  String get baseUrl => \'https://dev-api.example.com\';
}

@prod
@Injectable(as: ApiClient)        // registered only in prod
class ProdApiClient implements ApiClient {
  String get baseUrl => \'https://api.example.com\';
}''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'main.dart — pick your environment',
            code: '''// Development:
await configureDependencies(env: Environment.dev);
// getIt<ApiClient>() → DevApiClient

// Production:
await configureDependencies(env: Environment.prod);
// getIt<ApiClient>() → ProdApiClient''',
          ),
          const SizedBox(height: 8),
          const CodeBlock(
            label: 'injection.config.dart  (generated)',
            code: '''gh.factory<ApiClient>(
  () => DevApiClient(),
  registerFor: {Environment.dev},   // ← filtered out in prod
);
gh.factory<ApiClient>(
  () => ProdApiClient(),
  registerFor: {Environment.prod},  // ← filtered out in dev
);''',
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'LIVE DEMO', icon: Icons.play_arrow),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildEnvCard('dev', _devClient, const Color(0xFF16A34A))),
              const SizedBox(width: 10),
              Expanded(child: _buildEnvCard('prod', _prodClient, const Color(0xFFDC2626))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _devLoading ? null : _fetchDev,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A)),
                  child: _devLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Fetch (dev)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _prodLoading ? null : _fetchProd,
                  style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626)),
                  child: _prodLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Fetch (prod)'),
                ),
              ),
            ],
          ),
          if (_devResult != null || _prodResult != null) ...[
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_devResult != null)
                  Expanded(child: _buildResponse(_devResult!, const Color(0xFF16A34A))),
                if (_devResult != null && _prodResult != null)
                  const SizedBox(width: 10),
                if (_prodResult != null)
                  Expanded(child: _buildResponse(_prodResult!, const Color(0xFFDC2626))),
              ],
            ),
          ],
          const SizedBox(height: 12),
          InfoCard(
            title: 'This app started with Environment.dev',
            body:
                'getIt<ApiClient>() returns ${_devClient.runtimeType}. '
                'The prod side here is instantiated directly for comparison — '
                'in a real prod build, it\'s the registered one.',
            color: _color,
          ),
        ],
      ),
    );
  }

  Widget _buildEnvCard(String env, ApiClient client, Color color) {
    final isActive = env == 'dev';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withAlpha(isActive ? 100 : 40),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(4)),
                child: Text(env.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              if (isActive) ...[
                const SizedBox(width: 4),
                const Text('← active',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(client.runtimeType.toString(),
              style: TextStyle(
                  fontFamily: 'monospace', fontSize: 12, color: color)),
          const SizedBox(height: 2),
          Text(client.baseUrl,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildResponse(Map<String, dynamic> data, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries
            .map(
              (e) => Text(
                '"${e.key}": ${e.value is bool ? e.value : '"${e.value}"'}',
                style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFFE6EDF3)),
              ),
            )
            .toList(),
      ),
    );
  }
}
