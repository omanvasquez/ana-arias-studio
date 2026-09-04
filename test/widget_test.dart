import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ana_arias_studio/app.dart';

void main() {
  testWidgets('Base project widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AnaAriasStudioApp(),
      ),
    );

    expect(find.text('Ana Arias Studio'), findsWidgets);
    expect(find.text('Proyecto Base Configurado'), findsOneWidget);
  });
}
