import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/widgets/shimmer.dart';
import 'package:mdm_hris/features/root/presentation/widgets/dashboard_skeleton.dart';

void main() {
  testWidgets('DashboardSkeleton renders without overflow and animates shimmer', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const MaterialApp(
          home: DashboardSkeleton(),
        ),
      ),
    );

    // Initial frame
    expect(find.byType(DashboardSkeleton), findsOneWidget);
    expect(find.byType(Shimmer), findsAtLeastNWidgets(1));
    expect(find.byType(ShimmerBox), findsWidgets);

    // Advance animation timer
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });
}
