import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/workspace.dart';
import '../../../../../core/theme/app_colors.dart';

const reimbursementCategories = [
  'Transportasi',
  'Keperluan Kantor (Habis Pakai)',
  'Alat Tulis Kantor',
  'Peralatan Kantor (Aset)',
  'Biaya Sewa',
  'Entertain',
  'Subscription',
  'Lainnya',
];

/// Model draft rincian pengeluaran reimbursement
class ExpenseDraft {
  ExpenseDraft(Json row)
    : description = TextEditingController(text: text(row, 'description', '')),
      category = TextEditingController(text: text(row, 'category', '')),
      amount = TextEditingController(
        text: number(row, 'amount') > 0
            ? number(row, 'amount').toInt().toString()
            : '',
      ),
      date = DateTime.tryParse(text(row, 'date', '')) ?? DateTime.now(),
      receiptId = text(row, 'receiptId', '');

  final TextEditingController description, category, amount;
  DateTime date;
  String receiptId;
  String receiptName = 'Bukti tersimpan';

  Json json() => {
    'date': dateOnly(date),
    'description': description.text.trim(),
    'category': category.text.trim(),
    'amount': int.tryParse(amount.text) ?? 0,
    'receiptId': receiptId,
  };

  void dispose() {
    description.dispose();
    category.dispose();
    amount.dispose();
  }
}

/// Kartu Informasi Rekening Tujuan Pencairan Reimbursement
class ReimbursementAccountInfoCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final String accountName;
  final bool hasWorkspace;

  const ReimbursementAccountInfoCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
    this.hasWorkspace = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.account_balance_rounded,
                  size: 18,
                  color: Color(0xFF0D9488),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekening Tujuan Pencairan',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      !hasWorkspace
                          ? 'Rekening diambil dari data karyawan di sistem HRIS'
                          : '$bankName · $accountNumber ($accountName)',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Dana reimbursement akan ditransfer langsung ke rekening terdaftar di atas. Hubungi HR jika terdapat perubahan nomor rekening.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5.sp,
              color: const Color(0xFF94A3B8),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu Ringkasan Total Klaim Reimbursement
class ReimbursementSummaryCard extends StatelessWidget {
  final int totalExpenses;
  final int itemCount;

  const ReimbursementSummaryCard({
    super.key,
    required this.totalExpenses,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFF99F6E4),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total klaim',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F766E),
                      ),
                    ),
                    Text(
                      '$itemCount rincian pengeluaran',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: const Color(0xFF99F6E4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    rupiah(totalExpenses),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F766E),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          const Divider(
            height: 1,
            thickness: 0.8,
            color: Color(0xFFCCFBF1),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: Color(0xFF0D9488),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Setiap rincian wajib disertai bukti transaksi. Ketentuan template: pengajuan maksimal 14 hari kerja setelah transaksi.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    color: const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Kartu Baris Input Rincian Pengeluaran Reimbursement
class ReimbursementExpenseCard extends StatelessWidget {
  final ExpenseDraft item;
  final int index;
  final int totalCount;
  final String dateText;
  final bool disabled;
  final VoidCallback onRemove;
  final VoidCallback onPickDate;
  final VoidCallback onUploadReceipt;
  final VoidCallback? onPreviewReceipt;
  final VoidCallback? onRemoveReceipt;
  final ValueChanged<String>? onAmountChanged;
  final String? Function(String?) requiredValidator;

  const ReimbursementExpenseCard({
    super.key,
    required this.item,
    required this.index,
    required this.totalCount,
    required this.dateText,
    required this.disabled,
    required this.onRemove,
    required this.onPickDate,
    required this.onUploadReceipt,
    this.onPreviewReceipt,
    this.onRemoveReceipt,
    this.onAmountChanged,
    required this.requiredValidator,
  });

  Widget _buildInputWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ObjectKey(item),
      margin: EdgeInsets.only(bottom: 12.h),
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Badge Nomor dan Judul 'Pengeluaran N'
          Row(
            children: [
              Container(
                width: 22.w,
                height: 22.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF0D9488),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Pengeluaran ${index + 1}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          if (totalCount > 1) ...[
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: disabled ? null : onRemove,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 15,
                  color: AppColors.red,
                ),
                label: Text(
                  'Hapus rincian ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
          SizedBox(height: 12.h),

          // 1. Tanggal Transaksi
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled ? null : onPickDate,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Transaksi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: Color(0xFF0D9488),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text(
                            'Tanggal transaksi: $dateText',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // 2. Deskripsi Pengeluaran
          _buildInputWrapper(
            child: TextFormField(
              controller: item.description,
              enabled: !disabled,
              maxLength: 500,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                labelText: 'Deskripsi pengeluaran',
                hintText: 'Misal: Makan malam meeting client, bensin dinas',
                contentPadding: EdgeInsets.all(12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                      const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                ),
              ),
              validator: requiredValidator,
            ),
          ),
          SizedBox(height: 12.h),

          // 3. Kategori Pengeluaran (Dropdown)
          _buildInputWrapper(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButtonFormField<String>(
                initialValue: item.category.text.isNotEmpty ? item.category.text : null,
                isExpanded: true,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                ),
                hint: Text(
                  'Pilih kategori',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  labelText: 'Kategori pengeluaran *',
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                  contentPadding: EdgeInsets.all(12.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide:
                        const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                  ),
                ),
                items: [
                  ...reimbursementCategories,
                  if (item.category.text.isNotEmpty &&
                      !reimbursementCategories.contains(item.category.text))
                    item.category.text,
                ].map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: disabled
                    ? null
                    : (val) {
                        item.category.text = val ?? '';
                      },
                validator: requiredValidator,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // 4. Jumlah Pengeluaran (Rp)
          _buildInputWrapper(
            child: TextFormField(
              controller: item.amount,
              enabled: !disabled,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                labelText: 'Jumlah pengeluaran (Rp)',
                hintText: '0',
                prefixText: 'Rp ',
                prefixStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0D9488),
                ),
                contentPadding: EdgeInsets.all(12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                      const BorderSide(color: Color(0xFF0D9488), width: 1.5),
                ),
              ),
              onChanged: onAmountChanged,
              validator: (v) {
                final n = int.tryParse(v ?? '') ?? 0;
                return n < 1 || n > 1000000000000
                    ? 'Isi jumlah yang valid'
                    : null;
              },
            ),
          ),
          SizedBox(height: 12.h),

          // 5. Bukti Transaksi Attachment Card
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: item.receiptId.isNotEmpty
                  ? const Color(0xFFF0FDFA)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: item.receiptId.isNotEmpty
                    ? const Color(0xFF99F6E4)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: disabled ? null : onUploadReceipt,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Row(
                        children: [
                          Container(
                            width: 38.w,
                            height: 38.w,
                            decoration: BoxDecoration(
                              color: item.receiptId.isNotEmpty
                                  ? const Color(0xFF0D9488)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              item.receiptId.isNotEmpty
                                  ? Icons.file_present_rounded
                                  : Icons.upload_file_rounded,
                              size: 20,
                              color: item.receiptId.isNotEmpty
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.receiptId.isEmpty
                                      ? 'Unggah bukti transaksi'
                                      : 'Ganti bukti transaksi',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                    color: item.receiptId.isNotEmpty
                                        ? const Color(0xFF0D9488)
                                        : const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.receiptId.isEmpty
                                      ? 'JPEG, PNG, atau PDF; maksimal 2 MB'
                                      : item.receiptName,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.sp,
                                    color: item.receiptId.isNotEmpty
                                        ? const Color(0xFF0F766E)
                                        : const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (item.receiptId.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  if (onRemoveReceipt != null)
                    Tooltip(
                      message: 'Hapus berkas bukti',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: Key('delete_receipt_$index'),
                          onTap: disabled ? null : onRemoveReceipt,
                          borderRadius: BorderRadius.circular(6.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(6.r),
                              border: Border.all(
                                color: const Color(0xFFFECACA),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 14.sp,
                                  color: const Color(0xFFDC2626),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF0D9488),
                      size: 18,
                    ),
                ] else
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
              ],
            ),
          ),
          if (item.receiptId.isNotEmpty && onPreviewReceipt != null) ...[
            SizedBox(height: 6.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: disabled ? null : onPreviewReceipt,
                icon: const Icon(
                  Icons.image_search_outlined,
                  size: 15,
                  color: Color(0xFF0D9488),
                ),
                label: const Text(
                  'Lihat bukti yang diunggah',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D9488),
                  ),
                ),
                style: TextButton.styleFrom(
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
