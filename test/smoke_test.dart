import 'package:devportal_internal/app.dart';
import 'package:devportal_internal/di/app_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('hardcoded login gates the dashboard', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(AdminApp(deps: AppDependencies.bootstrap()));
    await tester.pumpAndSettle();

    // Unauthenticated → login gate.
    expect(find.text('DEVPORTAL'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'passWORD1234#');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    // Authenticated → admin dashboard.
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Approvals'), findsWidgets); // rail item
  });

  testWidgets('wrong password is rejected', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(AdminApp(deps: AppDependencies.bootstrap()));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), 'wrong');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Invalid username or password.'), findsOneWidget);
    expect(find.text('Operations'), findsNothing);
  });
}
