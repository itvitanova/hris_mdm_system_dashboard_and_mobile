import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import 'payroll/payroll_empty_state.dart';
import 'payroll/payroll_hero_banner.dart';
import 'payroll/payroll_search_bar.dart';
import 'payroll/payroll_slip_card.dart';
import 'payroll/period_filter_dropdown.dart';

export 'payroll/period_filter_dropdown.dart';

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

  @override
  Widget build(BuildContext context) {
    final allRows = w.mine('payroll')
      ..sort((a, b) => text(b, 'period').compareTo(text(a, 'period')));

    // Extract unique periods for filter dropdown
    final uniquePeriods = [
      'Semua periode',
      ...allRows
          .map((r) => text(r, 'period'))
          .where((p) => p.isNotEmpty)
          .toSet()
    ];

    if (!uniquePeriods.contains(selectedPeriod)) {
      selectedPeriod = 'Semua periode';
    }

    // Filter rows based on selectedPeriod and search query
    final filteredRows = allRows.where((r) {
      final matchesPeriod = selectedPeriod == 'Semua periode' ||
          text(r, 'period') == selectedPeriod;
      if (!matchesPeriod) return false;

      if (query.trim().isEmpty) return true;
      final q = query.trim().toLowerCase();
      final periodStr = text(r, 'period').toLowerCase();
      final companyStr = text(r, 'companyName').toLowerCase();
      final deptStr = text(r, 'department').toLowerCase();
      final statusStr = text(r, 'status').toLowerCase();

      return periodStr.contains(q) ||
          companyStr.contains(q) ||
          deptStr.contains(q) ||
          statusStr.contains(q);
    }).toList();

    final latestSlip = filteredRows.isNotEmpty ? filteredRows.first : null;
    final latestSalary =
        latestSlip != null ? number(latestSlip, 'netSalary') : 0;
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
              icon: Icon(
                UIcons.regularRounded.refresh,
                size: 20,
                color: const Color(0xFF0F766E),
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
              PayrollHeroBanner(
                latestSalary: latestSalary,
                latestPeriod: latestPeriod,
                selectedPeriod: selectedPeriod,
              ),
              SizedBox(height: 14.h),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: PayrollSearchBar(
                        controller: _searchController,
                        query: query,
                        onChanged: (v) => setState(() => query = v),
                        onClear: () {
                          _searchController.clear();
                          setState(() => query = '');
                        },
                      ),
                    ),
                    SizedBox(width: 8.w),
                    PeriodFilterDropdown(
                      key: const Key('payroll_period_dropdown_btn'),
                      selected: selectedPeriod,
                      options: uniquePeriods,
                      onChanged: (val) {
                        setState(() => selectedPeriod = val);
                      },
                    ),
                  ],
                ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 2.5.h,
                      ),
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
                PayrollEmptyState(
                  isFiltered:
                      selectedPeriod != 'Semua periode' || query.isNotEmpty,
                  onReset: () {
                    _searchController.clear();
                    setState(() {
                      selectedPeriod = 'Semua periode';
                      query = '';
                    });
                  },
                  onRefresh: widget.onRefresh,
                )
              else
                ...filteredRows.map(
                  (r) => PayrollSlipCard(
                    api: widget.api,
                    slip: r,
                    open: widget.open,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
