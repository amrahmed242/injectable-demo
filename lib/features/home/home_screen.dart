import 'package:flutter/material.dart';

import '../factory_demo/factory_demo_screen.dart';
import '../singleton_demo/singleton_demo_screen.dart';
import '../lazy_singleton_demo/lazy_singleton_screen.dart';
import '../named_demo/named_demo_screen.dart';
import '../environment_demo/environment_demo_screen.dart';
import '../module_demo/module_demo_screen.dart';
import '../async_demo/async_demo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _features = [
    _Feature(
      annotation: '@injectable',
      title: 'Factory',
      subtitle: 'New instance on every call — independent state per request.',
      icon: Icons.factory_outlined,
      color: Color(0xFF2563EB),
      screen: FactoryDemoScreen(),
    ),
    _Feature(
      annotation: '@singleton',
      title: 'Singleton',
      subtitle: 'One instance for the entire app lifetime — shared state.',
      icon: Icons.circle_outlined,
      color: Color(0xFF16A34A),
      screen: SingletonDemoScreen(),
    ),
    _Feature(
      annotation: '@lazySingleton',
      title: 'Lazy Singleton',
      subtitle: 'Like @singleton but created on first access — saves startup time.',
      icon: Icons.timelapse_outlined,
      color: Color(0xFF0891B2),
      screen: LazySingletonScreen(),
    ),
    _Feature(
      annotation: '@Named()',
      title: 'Named Registrations',
      subtitle: 'Multiple implementations of the same interface, distinguished by name.',
      icon: Icons.label_outline,
      color: Color(0xFF7C3AED),
      screen: NamedDemoScreen(),
    ),
    _Feature(
      annotation: '@dev / @prod',
      title: 'Environment Scoping',
      subtitle: 'Register different implementations per environment at compile time.',
      icon: Icons.tune_outlined,
      color: Color(0xFFD97706),
      screen: EnvironmentDemoScreen(),
    ),
    _Feature(
      annotation: '@module',
      title: 'Modules',
      subtitle: 'Register third-party classes you cannot annotate directly.',
      icon: Icons.extension_outlined,
      color: Color(0xFFDC2626),
      screen: ModuleDemoScreen(),
    ),
    _Feature(
      annotation: '@factoryMethod (async)',
      title: 'Async Initialization',
      subtitle: 'Inject dependencies that require async setup — DB, I/O, network.',
      icon: Icons.sync_outlined,
      color: Color(0xFF4338CA),
      screen: AsyncDemoScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('injectable'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DI Playground',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(140),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap any feature to explore it interactively.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(100),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  if (i < _features.length) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _FeatureCard(feature: _features[i]),
                    );
                  }
                  if (i == _features.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      child: Center(
                        child: Text(
                          'powered by injectable · get_it',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withAlpha(80),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                childCount: _features.length + 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withAlpha(40),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => feature.screen),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: feature.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(feature.icon, color: feature.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: feature.color.withAlpha(15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: feature.color.withAlpha(60)),
                          ),
                          child: Text(
                            feature.annotation,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: feature.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          feature.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color:
                    Theme.of(context).colorScheme.onSurface.withAlpha(80),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature {
  final String annotation;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _Feature({
    required this.annotation,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}
