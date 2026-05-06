import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart';

import 'package:injectable_example/app.dart';
import 'package:injectable_example/di/injection.dart';

void main() {
  setUpAll(() async {
    await configureDependencies(env: Environment.dev);
  });

  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pump();
    expect(find.text('injectable'), findsOneWidget);
  });
}
