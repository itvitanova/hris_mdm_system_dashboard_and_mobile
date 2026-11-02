import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

void main() {
  testWidgets('LanguageSwapButton displays ID and ENG in slim popup without checkmark', (tester) async {
    AppLanguage? selected;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: LanguageSwapButton(
                initialLanguage: AppLanguage.id,
                onLanguageChanged: (lang) => selected = lang,
              ),
            ),
          ),
        ),
      ),
    );

    // Initial state displays "ID"
    expect(find.text('ID'), findsOneWidget);
    expect(find.text('🇮🇩'), findsOneWidget);

    // Tap to open popup
    await tester.tap(find.byKey(const Key('dashboard_language_swap_button')));
    await tester.pumpAndSettle();

    // Popup items display "ID" and "ENG"
    expect(find.text('ENG'), findsOneWidget);
    expect(find.text('🇬🇧'), findsOneWidget);
    // Checkmark icon is removed for slim minimalist style
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    // Select ENG
    await tester.tap(find.text('ENG'));
    await tester.pumpAndSettle();

    expect(selected, AppLanguage.en);
    expect(find.text('ENG'), findsOneWidget);
    expect(find.text('Language switched to English'), findsOneWidget);
  });
}
