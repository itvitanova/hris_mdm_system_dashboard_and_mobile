import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'module_page_number_button.dart';

/// Pagination bar with page summary, range description, and numbered navigation
class ModulePaginationBar extends StatelessWidget {
  const ModulePaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.startIndex,
    required this.endIndex,
    required this.totalItems,
    required this.isEn,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final int startIndex;
  final int endIndex;
  final int totalItems;
  final bool isEn;
  final ValueChanged<int> onPageChanged;

  static List<int> calculateVisiblePages(int current, int total) {
    if (total <= 5) return List.generate(total, (i) => i + 1);
    int start = (current - 2).clamp(1, (total - 4).clamp(1, total));
    int end = (start + 4).clamp(1, total);
    return List.generate(end - start + 1, (i) => start + i);
  }

  @override
  Widget build(BuildContext context) {
    final hasPrev = currentPage > 1;
    final hasNext = currentPage < totalPages;
    final visiblePages = calculateVisiblePages(currentPage, totalPages);

    return Container(
      key: const ValueKey('pagination_bar'),
      margin: EdgeInsets.only(top: 4.h, bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tombol Panah Kiri (<)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_prev_btn'),
                  onTap: hasPrev ? () => onPageChanged(currentPage - 1) : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasPrev
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasPrev
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      UIcons.regularRounded.angle_small_left,
                      size: 20.sp,
                      color: hasPrev
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),

              // Info Halaman & Rentang di Tengah
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEn
                            ? 'Page $currentPage of $totalPages'
                            : 'Halaman $currentPage dari $totalPages',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        totalItems == 0
                            ? (isEn ? 'No submissions' : 'Tidak ada pengajuan')
                            : (isEn
                                ? 'Showing ${startIndex + 1}\u2013$endIndex of $totalItems submissions'
                                : 'Menampilkan ${startIndex + 1}\u2013$endIndex dari $totalItems pengajuan'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol Panah Kanan (>)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  key: const ValueKey('pagination_next_btn'),
                  onTap: hasNext ? () => onPageChanged(currentPage + 1) : null,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: hasNext
                          ? const Color(0xFFF8FAFC)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: hasNext
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFFE2E8F0),
                        width: 0.8,
                      ),
                    ),
                    child: Icon(
                      UIcons.regularRounded.angle_small_right,
                      size: 20.sp,
                      color: hasNext
                          ? const Color(0xFF0F172A)
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (totalPages > 1) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final page in visiblePages)
                  ModulePageNumberButton(
                    page: page,
                    isActive: page == currentPage,
                    onTap: () => onPageChanged(page),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
