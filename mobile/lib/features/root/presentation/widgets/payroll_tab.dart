import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../payroll/payslip_screen.dart';

class PayrollTab extends StatefulWidget {
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

  @override
  State<PayrollTab> createState() => _PayrollTabState();
}

class _PayrollTabState extends State<PayrollTab> {
  String selectedPeriod = 'Semua Periode';

  Workspace get w => widget.workspace;

  Widget _buildHeroSummaryBanner(num latestSalary, String latestPeriod, int totalSlips) {
    final hasFilter = selectedPeriod != 'Semua Periode';
    final chipLabel = hasFilter
        ? 'Filter: $selectedPeriod'
        : (latestPeriod.isNotEmpty
            ? 'Periode Terkini: $latestPeriod'
            : 'Portal Slip Gaji Karyawan');

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140F766E),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 105.w,
              height: 105.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -30.h,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.6,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5.5.w,
                        height: 5.5.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4ADE80),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 5.w),
                      Flexible(
                        child: Text(
                          chipLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  latestSalary > 0 ? rupiah(latestSalary) : 'Rp 0',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  hasFilter
                      ? 'Total penerimaan take-home pay pada periode $selectedPeriod.'
                      : (latestSalary > 0
                          ? 'Total take-home pay penerimaan gaji terakhir Anda.'
                          : 'Data slip gaji resmi diterbitkan secara periodik oleh Finance.'),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodFilterBar(List<String> periods) {
    if (periods.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final p = periods[index];
          final isSelected = p == selectedPeriod;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('payroll_period_filter_$p'),
              borderRadius: BorderRadius.circular(20.r),
              onTap: () => setState(() => selectedPeriod = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0F766E), // Teal 700
                            Color(0xFF14B8A6), // Teal 500
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF0F766E)
                                .withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ]
                      : [
                          const BoxShadow(
                            color: Color(0x050F172A),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (p != 'Semua Periode') ...[
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 11.sp,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                      ),
                      SizedBox(width: 5.w),
                    ],
                    Text(
                      p,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isFinal = status.toLowerCase() == 'final';
    final bg = isFinal ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final textCol = isFinal ? const Color(0xFF166534) : const Color(0xFF92400E);
    final borderCol = isFinal ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A);
    final icon = isFinal ? Icons.check_circle_rounded : Icons.schedule_rounded;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderCol, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: textCol),
          SizedBox(width: 4.w),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w600,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool isFiltered}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 26,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isFiltered ? 'Tidak Ada Slip untuk Periode Ini' : 'Slip Gaji Belum Tersedia',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isFiltered
                ? 'Tidak ditemukan dokumen slip gaji pada periode $selectedPeriod.'
                : 'Data slip gaji Anda untuk periode ini belum diterbitkan oleh bagian Finance/HR.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          SizedBox(height: 16.h),
          if (isFiltered)
            ElevatedButton.icon(
              onPressed: () => setState(() => selectedPeriod = 'Semua Periode'),
              icon: const Icon(Icons.clear_all_rounded, size: 16),
              label: const Text('Tampilkan Semua Periode'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: widget.onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Muat Ulang Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F766E),
                side: const BorderSide(color: Color(0xFF0F766E), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPayslipCard(BuildContext context, Json r) {
    final period = text(r, 'period');
    final status = text(r, 'status', 'Final');
    final company = text(r, 'companyName', 'PT MDM Human Resource');
    final department = text(r, 'department');
    final netSalary = number(r, 'netSalary');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => widget.open(PayslipScreen(api: widget.api, slip: r)),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDFA),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFCCFBF1),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 20,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            period,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            department.isNotEmpty ? '$company • $department' : company,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildStatusBadge(status),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 1,
                  color: const Color(0xFFF1F5F9),
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gaji Bersih (Take Home Pay)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            rupiah(netSalary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F766E),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Rincian',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F766E),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 15.sp,
                            color: const Color(0xFF0F766E),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allRows = w.mine('payroll')
      ..sort((a, b) => text(b, 'period').compareTo(text(a, 'period')));

    // Extract unique periods for filter bar
    final uniquePeriods = [
      'Semua Periode',
      ...allRows.map((r) => text(r, 'period')).where((p) => p.isNotEmpty).toSet()
    ];

    if (!uniquePeriods.contains(selectedPeriod)) {
      selectedPeriod = 'Semua Periode';
    }

    // Filter rows based on selectedPeriod
    final filteredRows = selectedPeriod == 'Semua Periode'
        ? allRows
        : allRows.where((r) => text(r, 'period') == selectedPeriod).toList();

    final latestSlip = filteredRows.isNotEmpty ? filteredRows.first : null;
    final latestSalary = latestSlip != null ? number(latestSlip, 'netSalary') : 0;
    final latestPeriod = latestSlip != null ? text(latestSlip, 'period') : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        titleSpacing: 20,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Slip Gaji',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              'Rincian & Riwayat Pembayaran Gaji',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 38.w,
            height: 38.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
                color: Color(0xFF0F766E),
              ),
              padding: EdgeInsets.zero,
              tooltip: 'Segarkan data',
              onPressed: widget.onRefresh,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: const Color(0xFF0F766E),
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            children: [
              _buildHeroSummaryBanner(latestSalary, latestPeriod, filteredRows.length),
              if (uniquePeriods.length > 2) ...[
                SizedBox(height: 14.h),
                _buildPeriodFilterBar(uniquePeriods),
              ],
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Riwayat Pembayaran',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (filteredRows.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        '${filteredRows.length} Periode',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 12.h),
              if (filteredRows.isEmpty)
                _buildEmptyState(isFiltered: selectedPeriod != 'Semua Periode')
              else
                ...filteredRows.map((r) => _buildPayslipCard(context, r)),
            ],
          ),
        ),
      ),
    );
  }
}
