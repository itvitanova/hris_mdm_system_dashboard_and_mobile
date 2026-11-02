import 'package:flutter/material.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets.dart';
import '../../../payroll/payslip_screen.dart';

class PayrollTab extends StatelessWidget {
  const PayrollTab({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.open,
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Widget) open;

  Workspace get w => workspace;

  @override
  Widget build(BuildContext context) {
    final rows = w.mine('payroll')
      ..sort((a, b) => text(b, 'period').compareTo(text(a, 'period')));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Slip Gaji',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan data',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const SectionHeading(
                'Pendapatan Anda',
                subtitle: 'Rincian pendapatan dan potongan per periode.',
              ),
              const SizedBox(height: 20),
              if (rows.isEmpty)
                const EmptyState('Slip gaji belum tersedia.')
              else
                ...rows.map(
                  (r) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      title: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            text(r, 'period'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          StatusPill(text(r, 'status')),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          rupiah(number(r, 'netSalary')),
                          style: const TextStyle(
                            color: AppColors.deepTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 23,
                          ),
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => open(PayslipScreen(api: api, slip: r)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
