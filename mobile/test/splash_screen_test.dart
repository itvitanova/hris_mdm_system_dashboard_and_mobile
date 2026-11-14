import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/features/splash/presentation/pages/splash_screen.dart';

void main() {
  testWidgets('SplashScreen renders white background and invokes callback gracefully', (tester) async {
    bool completed = false;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MaterialApp(
          home: SplashScreen(
            fallbackTimeout: const Duration(milliseconds: 100),
            onAnimationComplete: () {
              completed = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.white);

    // Advance time past the fallback timeout
    await tester.pump(const Duration(milliseconds: 150));
    expect(completed, isTrue);
  });
}
