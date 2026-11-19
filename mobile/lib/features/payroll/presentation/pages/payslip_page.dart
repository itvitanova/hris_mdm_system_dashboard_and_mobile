import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../widgets/payslip/payslip_app_bar.dart';
import '../widgets/payslip/payslip_deductions_card.dart';
import '../widgets/payslip/payslip_download_button.dart';
import '../widgets/payslip/payslip_earnings_card.dart';
import '../widgets/payslip/payslip_hero_card.dart';
import '../widgets/payslip/payslip_meta_card.dart';
import '../widgets/payslip/payslip_share_service.dart';

/// Halaman Rincian Slip Gaji
class PayslipScreen extends StatefulWidget {
  const PayslipScreen({
    super.key,
    required this.api,
    required this.slip,
  });

  final ApiClient api;
  final Json slip;

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  bool busy = false;

  Future<void> _handleShare() async {
    await PayslipShareService.share(
      context: context,
      api: widget.api,
      slip: widget.slip,
      onBusyChanged: (state) {
        if (mounted) setState(() => busy = state);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.slip;
    final v2 = number(p, 'version') >= 2;
    final period = text(p, 'period');
    final employeeName = text(p, 'employeeName');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PayslipAppBar(
        period: period,
        employeeName: employeeName,
        busy: busy,
        onShare: _handleShare,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          children: [
            PayslipHeroCard(slip: p),
            SizedBox(height: 14.h),
            PayslipMetaCard(slip: p, isV2: v2),
            SizedBox(height: 14.h),
            PayslipEarningsCard(slip: p, isV2: v2),
            SizedBox(height: 14.h),
            PayslipDeductionsCard(slip: p, isV2: v2),
            SizedBox(height: 20.h),
            PayslipDownloadButton(
              busy: busy,
              onPressed: _handleShare,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

typedef PayslipPage = PayslipScreen;
