import 'package:devportal_internal/app.dart';
import 'package:devportal_internal/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Full UI journeys for the internal admin console, driven through the real
/// widget tree at a desktop viewport.
void main() {
  Future<void> bootAndLogin(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(AdminApp(deps: AppDependencies.bootstrap()));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'passWORD1234#');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
  }

  testWidgets('login lands on the operations dashboard', (tester) async {
    await bootAndLogin(tester);
    expect(find.text('Operations'), findsOneWidget);
    expect(find.textContaining('awaiting approval'), findsOneWidget);
  });

  testWidgets('creating a product adds it to the catalog', (tester) async {
    await bootAndLogin(tester);

    await tester.tap(find.text('Products')); // rail
    await tester.pumpAndSettle();
    expect(find.text('API products'), findsOneWidget);
    expect(find.text('Payment Initiation API'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'New product'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'CI New API');
    await tester.tap(find.widgetWithText(FilledButton, 'Create product'));
    await tester.pumpAndSettle();

    expect(find.text('CI New API'), findsOneWidget); // back in the list
  });

  testWidgets('approving a request removes it from the queue', (tester) async {
    await bootAndLogin(tester);

    await tester.tap(find.text('Approvals')); // rail
    await tester.pumpAndSettle();
    expect(find.text('Approval queue'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Approve & issue keys'),
        findsNWidgets(3));

    await tester
        .tap(find.widgetWithText(FilledButton, 'Approve & issue keys').first);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, 'Approve & issue keys'),
        findsNWidgets(2));
  });

  testWidgets('developers and analytics pages load', (tester) async {
    await bootAndLogin(tester);

    await tester.tap(find.text('Developers'));
    await tester.pumpAndSettle();
    expect(find.text('Priya Nair'), findsOneWidget);

    await tester.tap(find.text('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Top products'), findsOneWidget);
  });
}
