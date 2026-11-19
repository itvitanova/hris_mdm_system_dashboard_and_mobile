import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import 'detail_formatters.dart';
import 'detail_section_card.dart';

/// Card displaying breakdown list of expense items for reimbursement
class DetailExpenseItemsCard extends StatelessWidget {
  const DetailExpenseItemsCard({
    super.key,
    required this.items,
    required this.amount,
  });

  final List<Json> items;
  final num amount;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return DetailSectionCard(
      icon: UIcons.regularRounded.receipt,
      title: 'Rincian Pengeluaran',
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          '${items.length} item',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 4.h),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: const Divider(
                    height: 1, thickness: 0.8, color: Color(0xFFF1F5F9)),
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          DetailFormatters.getExpenseCategoryIcon(
                              text(items[i], 'category')),
                          size: 17.w,
                          color: const Color(0xFF475569),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 160.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DetailFormatters.cleanItemDescription(
                                  text(items[i], 'description')),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 5.w,
                              runSpacing: 2.h,
                              children: [
                                Text(text(items[i], 'category', 'Item'),
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 11.sp, fontWeight: FontWeight.w500, color: const Color(0xFF64748B))),
                                Text('•', style: TextStyle(fontSize: 10.sp, color: const Color(0xFFCBD5E1))),
                                Text(requestDateLabel(text(items[i], 'date')),
                                    style: TextStyle(fontFamily: 'Inter', fontSize: 11.sp, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    rupiah(number(items[i], 'amount')),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.only(top: 14.h, bottom: 12.h),
            child: const Divider(
                height: 1, thickness: 0.8, color: Color(0xFFE2E8F0)),
          ),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Pengeluaran',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    '${items.length} transaksi tercatat',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              Text(
                rupiah(amount),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.5.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
