import '../../../../../core/workspace.dart';
import '../../models/expense_draft.dart';
import '../../models/request_form_controllers.dart';
import '../form_sections/petty_cash_form_section.dart';

const gaCategories = [
  'Pengadaan Barang',
  'Perbaikan & Servis',
  'Kebutuhan ATK',
  'Pemeliharaan Fasilitas',
  'Sarana Ruang Rapat',
];

const gaPriorities = ['Normal', 'Mendesak'];

typedef RequestMetaCallback = void Function(
  String gaCategory,
  String gaPriority,
  String? selectedIzinType,
  String? attachmentName,
  String? attachmentId,
  DateTime? start,
  DateTime? end,
);

/// Helper to parse initial request metadata for revisions and drafts
class RequestFormInitialData {
  static void populateControllers({
    required Json r,
    required RequestFormControllers c,
    required List<ExpenseDraft> expenses,
    required RequestMetaCallback onMeta,
  }) {
    String gaCategory = 'Pengadaan Barang';
    String gaPriority = 'Normal';
    String? selectedIzinType;
    String? attachmentName;
    String? attachmentId;
    DateTime? start;
    DateTime? end;

    populate(
      r: r,
      setTitle: (v) => c.title.text = v,
      setDescription: (v) => c.description.text = v,
      setGaCategory: (v) => gaCategory = v,
      setSelectedIzinType: (v) => selectedIzinType = v,
      setGaPriority: (v) => gaPriority = v,
      setLocation: (v) => c.location.text = v,
      setAttachmentName: (v) => attachmentName = v,
      setAttachmentId: (v) => attachmentId = v,
      setAmount: (v) => c.amount.text = v > 0 ? formatThousand(v) : '',
      setHours: (v) => c.hours.text = v,
      setStart: (v) => start = v,
      setEnd: (v) => end = v,
      expenses: expenses,
    );

    onMeta(
      gaCategory,
      gaPriority,
      selectedIzinType,
      attachmentName,
      attachmentId,
      start,
      end,
    );
  }

  static void populate({
    required Json r,
    required void Function(String) setTitle,
    required void Function(String) setDescription,
    required void Function(String) setGaCategory,
    required void Function(String) setSelectedIzinType,
    required void Function(String) setGaPriority,
    required void Function(String) setLocation,
    required void Function(String) setAttachmentName,
    required void Function(String) setAttachmentId,
    required void Function(int) setAmount,
    required void Function(String) setHours,
    required void Function(DateTime) setStart,
    required void Function(DateTime) setEnd,
    required List<ExpenseDraft> expenses,
  }) {
    setTitle(text(r, 'title', ''));
    final desc = text(r, 'description', '');
    final metadataMatch = RegExp(r'\n\n\[(.*?)\]$').firstMatch(desc);
    if (metadataMatch != null) {
      setDescription(desc.substring(0, metadataMatch.start).trim());
      final rawMeta = metadataMatch.group(1) ?? '';
      for (final p in rawMeta.split(' · ')) {
        if (p.startsWith('Kategori: ')) setGaCategory(p.substring(10).trim());
        if (p.startsWith('Jenis Izin: ')) setSelectedIzinType(p.substring(12).trim());
        if (p.startsWith('Prioritas: ')) setGaPriority(p.substring(11).trim());
        if (p.startsWith('Lokasi: ')) setLocation(p.substring(8).trim());
        if (p.startsWith('Lampiran: ')) setAttachmentName(p.substring(10).trim());
      }
    } else {
      setDescription(desc);
    }
    setAmount(number(r, 'amount').toInt());
    setHours(number(r, 'hours').toString());
    final s = DateTime.tryParse(text(r, 'startDate', ''));
    if (s != null) setStart(s);
    final e = DateTime.tryParse(text(r, 'endDate', ''));
    if (e != null) setEnd(e);

    final att = text(r, 'attachmentName', '');
    if (att.isNotEmpty && att != '—') setAttachmentName(att);
    final attId = text(r, 'attachmentId', '');
    if (attId.isNotEmpty) setAttachmentId(attId);

    final cat = text(r, 'category', '');
    if (gaCategories.contains(cat)) setGaCategory(cat);
    final prio = text(r, 'priority', '');
    if (gaPriorities.contains(prio)) setGaPriority(prio);
    if (text(r, 'location', '').isNotEmpty) setLocation(text(r, 'location', ''));

    final permType = text(r, 'permissionType', '');
    if (permType.isNotEmpty) {
      setSelectedIzinType(permType);
    } else if (cat.isNotEmpty) {
      setSelectedIzinType(cat);
    }

    final items = (r['items'] as List?) ?? [];
    if (items.isNotEmpty) {
      expenses.clear();
      for (final item in items) {
        if (item is Map<String, dynamic>) {
          expenses.add(ExpenseDraft(item));
        } else if (item is Map) {
          expenses.add(ExpenseDraft(Map<String, dynamic>.from(item)));
        }
      }
    }
  }
}
