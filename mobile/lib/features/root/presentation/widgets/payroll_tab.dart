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
  String selectedPeriod = 'Semua periode';
  String query = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Workspace get w => widget.workspace;

  Widget _buildHeroSummaryBanner(num latestSalary, String latestPeriod, int totalSlips) {
    final hasFilter = selectedPeriod != 'Semua periode';
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

  Widget _buildSearchBar() {
    return Container(
      height: 42.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari slip gaji…',
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 19,
            color: Color(0xFF94A3B8),
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 17, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
        ),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          color: Color(0xFF0F172A),
        ),
        onChanged: (v) => setState(() => query = v),
      ),
    );
  }

  Widget _buildPeriodDropdownTrigger(List<String> uniquePeriods) {
    final isCustomPeriod = selectedPeriod != 'Semua periode';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const Key('payroll_period_dropdown_btn'),
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _showPeriodPickerModal(context, uniquePeriods),
        child: Container(
          height: 42.h,
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isCustomPeriod ? const Color(0xFF0F766E) : const Color(0xFFE2E8F0),
              width: isCustomPeriod ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 15.sp,
                color: isCustomPeriod ? const Color(0xFF0F766E) : const Color(0xFF64748B),
              ),
              SizedBox(width: 6.w),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 96.w),
                child: Text(
                  selectedPeriod,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: isCustomPeriod ? FontWeight.w700 : FontWeight.w600,
                    color: isCustomPeriod ? const Color(0xFF0F766E) : const Color(0xFF1E293B),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.sp,
                color: isCustomPeriod ? const Color(0xFF0F766E) : const Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPeriodPickerModal(BuildContext context, List<String> uniquePeriods) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Periode payroll',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (selectedPeriod != 'Semua periode')
                      TextButton(
                        onPressed: () {
                          setState(() => selectedPeriod = 'Semua periode');
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F766E),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                ...uniquePeriods.map((period) {
                  final isSelected = period == selectedPeriod;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: ValueKey('period_option_$period'),
                      borderRadius: BorderRadius.circular(10.r),
                      onTap: () {
                        setState(() => selectedPeriod = period);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        margin: EdgeInsets.only(bottom: 6.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF0FDFA) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0F766E) : const Color(0xFFF1F5F9),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              period == 'Semua periode'
                                  ? Icons.date_range_rounded
                                  : Icons.calendar_today_rounded,
                              size: 16.sp,
                              color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                period,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                size: 18.sp,
                                color: const Color(0xFF0F766E),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
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
            isFiltered ? 'Tidak Ada Slip yang Sesuai' : 'Slip Gaji Belum Tersedia',
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
                ? 'Tidak ditemukan dokumen slip gaji yang sesuai dengan filter pencarian atau periode terpilih.'
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
              onPressed: () {
                _searchController.clear();
                setState(() {
                  selectedPeriod = 'Semua periode';
                  query = '';
                });
              },
              icon: const Icon(Icons.clear_all_rounded, size: 16),
              label: const Text('Reset Filter & Pencarian'),
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

    // Extract unique periods for filter dropdown
    final uniquePeriods = [
      'Semua periode',
      ...allRows.map((r) => text(r, 'period')).where((p) => p.isNotEmpty).toSet()
    ];

    if (!uniquePeriods.contains(selectedPeriod)) {
      selectedPeriod = 'Semua periode';
    }

    // Filter rows based on selectedPeriod and search query
    final filteredRows = allRows.where((r) {
      final matchesPeriod = selectedPeriod == 'Semua periode' || text(r, 'period') == selectedPeriod;
      if (!matchesPeriod) return false;

      if (query.trim().isEmpty) return true;
      final q = query.trim().toLowerCase();
      final periodStr = text(r, 'period').toLowerCase();
      final companyStr = text(r, 'companyName').toLowerCase();
      final deptStr = text(r, 'department').toLowerCase();
      final statusStr = text(r, 'status').toLowerCase();

      return periodStr.contains(q) || companyStr.contains(q) || deptStr.contains(q) || statusStr.contains(q);
    }).toList();

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
              SizedBox(height: 14.h),
              Row(
                children: [
                  Expanded(
                    child: _buildSearchBar(),
                  ),
                  SizedBox(width: 8.w),
                  _buildPeriodDropdownTrigger(uniquePeriods),
                ],
              ),
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
                        '${filteredRows.length} Dokumen',
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
                _buildEmptyState(isFiltered: selectedPeriod != 'Semua periode' || query.isNotEmpty)
              else
                ...filteredRows.map((r) => _buildPayslipCard(context, r)),
            ],
          ),
        ),
      ),
    );
  }
}
