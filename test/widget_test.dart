// Flutter widget smoke test for تطبيق (حفلة).
//
// Verifies the splash screen shows the animated app name, then the
// 5-second loading bar auto-navigates into the home screen.

import 'package:flutter_test/flutter_test.dart';

import 'package:partyapp/main.dart';

void main() {
  testWidgets('Splash shows app name, then opens home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // Splash visible with loading indicator and caret start.
    expect(find.text('جاري الدخول...'), findsOneWidget);
    expect(find.text('مناسبتك تبدأ من هنا'), findsOneWidget);

    // Advance past the 5s splash animation + route transition.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Now on the home screen.
    expect(find.text('أقسامنا'), findsOneWidget);
    expect(find.text('حدد المحافظة'), findsOneWidget);
    expect(find.text('المصورين'), findsOneWidget);
    expect(find.text('القاعات'), findsOneWidget);
  });
}