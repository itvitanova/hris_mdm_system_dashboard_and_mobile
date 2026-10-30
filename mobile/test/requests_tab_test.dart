import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/presentation/pages/modules/dedicated_module_screen.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/service_module_card.dart';
import 'package:mdm_hris/features/root/presentation/widgets/requests_tab.dart';

void main() {
  group('RequestsTab Hub Portal Tests', () {
    testWidgets(
      'renders 5 service cards and opens DedicatedModuleScreen on tap',
      (tester) async {
        final workspace = Workspace({
          'requests': [],
          'employees': [],
          'attendancePolicy': {},
        });
        Widget? openedWidget;

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp(
              home: RequestsTab(
                api: ApiClient(),
                workspace: workspace,
                onRefresh: () async {},
                open: (w) async => openedWidget = w,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify 5 Service Cards in catalog
        expect(find.text('Katalog Pengajuan'), findsOneWidget);
        expect(find.byType(ServiceModuleCard), findsNWidgets(5));
        expect(find.text('Cuti & Izin'), findsOneWidget);
        expect(find.text('Lembur'), findsOneWidget);
        expect(find.text('Reimbursement'), findsOneWidget);
        expect(find.text('Petty Cash'), findsOneWidget);
        expect(find.text('General Affair'), findsOneWidget);

        // 2. Verify Pengajuan Terkini section
        await tester.scrollUntilVisible(
          find.text('Pengajuan Terkini'),
          150,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text('Pengajuan Terkini'), findsOneWidget);

        // 3. Tap Cuti & Izin card -> routes to DedicatedModuleScreen
        await tester.tap(find.text('Cuti & Izin'));
        await tester.pumpAndSettle();

        expect(openedWidget, isA<DedicatedModuleScreen>());
        final screen = openedWidget as DedicatedModuleScreen;
        expect(screen.moduleTitle, 'Pengajuan Cuti & Izin');
        expect(screen.keyMetricLabel, 'SISA KUOTA');
      },
    );
  });
}
