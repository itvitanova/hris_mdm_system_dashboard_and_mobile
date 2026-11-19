import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';

class AttendanceHistoryPaginationBar extends StatelessWidget {
  const AttendanceHistoryPaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.totalItems,
    required this.language,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int startIndex;
  final int endIndex;
  final int totalItems;
  final AppLanguage language;
  final ValueChanged<int> onPageChanged;

  List<int> _calculateVisiblePages(int current, int total) {
    if (total <= 5) return List.generate(total, (i) => i + 1);
    int start = (current - 2).clamp(1, (total - 4).clamp(1, total));
    int end = (start + 4).clamp(1, total);
    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    final hasPrev = currentPage > 1;
    final hasNext = currentPage < totalPages;
    final visiblePages = _calculateVisiblePages(currentPage, totalPages);
    final isEn = language == AppLanguage.en;

    return Container(
      key: const ValueKey('pagination_bar'),
      margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEn
                ? 'Page $currentPage of $totalPages'
                : 'Halaman $currentPage dari $totalPages',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            totalItems == 0
                ? (isEn ? 'No attendance records' : 'Tidak ada catatan kehadiran')
                : (isEn
                    ? 'Showing ${startIndex + 1}\u2013$endIndex of $totalItems attendance records'
                    : 'Menampilkan ${startIndex + 1}\u2013$endIndex dari $totalItems catatan kehadiran'),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildArrowBtn(
                key: const ValueKey('pagination_prev_btn'),
                isEnabled: hasPrev,
                icon: UIcons.regularRounded.angle_small_left,
                onTap: hasPrev ? () => onPageChanged(currentPage - 1) : null,
              ),
              SizedBox(width: 6.w),
              ...visiblePages.map((page) => _buildPageBtn(page, page == currentPage)),
              SizedBox(width: 6.w),
              _buildArrowBtn(
                key: const ValueKey('pagination_next_btn'),
                isEnabled: hasNext,
                icon: UIcons.regularRounded.angle_small_right,
                onTap: hasNext ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrowBtn({
    required Key key,
    required bool isEnabled,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: key,
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 34.w,
          height: 34.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: isEnabled ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: isEnabled ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildPageBtn(int page, bool isActive) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? null : () => onPageChanged(page),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0D9488) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isActive ? const Color(0xFF0D9488) : const Color(0xFFCBD5E1),
                width: 0.8,
              ),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
