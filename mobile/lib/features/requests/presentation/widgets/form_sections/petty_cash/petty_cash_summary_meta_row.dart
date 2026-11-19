import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'petty_cash_category_selector.dart';

class PettyCashSummaryMetaRow extends StatelessWidget {
  final String category;
  final String dateText;

  const PettyCashSummaryMetaRow({
    super.key,
    required this.category,
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildMetaCard(
              icon: getPettyCashCategoryIcon(category),
              label: 'Kategori',
              value: category,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: _buildMetaCard(
              icon: UIcons.regularRounded.calendar,
              label: 'Tanggal',
              value: dateText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xD9FFFFFF),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: const Color(0xFFCCFBF1),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  icon,
                  size: 14.sp,
                  color: const Color(0xFF0D9488),
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
