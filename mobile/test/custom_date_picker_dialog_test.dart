import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/custom_date_picker_dialog.dart';

void main() {
  testWidgets('custom date picker dialog opens, navigates month, and returns selected date', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    selected = await showCustomDatePickerDialog(
                      context: context,
                      initialDate: DateTime(2026, 11, 1),
                      firstDate: DateTime(2025, 1, 1),
                      lastDate: DateTime(2030, 12, 31),
                      title: 'PILIH TANGGAL MULAI',
                    );
                  },
                  child: const Text('Buka Dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Tap button to open date picker dialog
    await tester.tap(find.text('Buka Dialog'));
    await tester.pumpAndSettle();

    // Verify Title & header elements
    expect(find.text('PILIH TANGGAL MULAI'), findsOneWidget);
    expect(find.text('November 2026'), findsOneWidget);
    expect(find.text('Hari Ini'), findsOneWidget);
    expect(find.text('Besok'), findsOneWidget);
    expect(find.text('7 Hari ke Depan'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);
    expect(find.text('Terapkan'), findsOneWidget);

    // Tap day 15 in the current month view
    final day15 = find.widgetWithText(GestureDetector, '15').first;
    await tester.tap(day15);
    await tester.pumpAndSettle();

    // Tap Terapkan button
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    // Verify selected date
    expect(selected, isNotNull);
    expect(selected!.year, 2026);
    expect(selected!.month, 11);
    expect(selected!.day, 15);
  });

  testWidgets('custom date picker dialog closes on Batal without selection', (
    tester,
  ) async {
    DateTime? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    selected = await showCustomDatePickerDialog(
                      context: context,
                      initialDate: DateTime(2026, 11, 1),
                      title: 'PILIH TANGGAL SELESAI',
                    );
                  },
                  child: const Text('Buka Dialog'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Buka Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('PILIH TANGGAL SELESAI'), findsOneWidget);

    // Tap Batal
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.byType(CustomDatePickerDialog), findsNothing);
  });
}
