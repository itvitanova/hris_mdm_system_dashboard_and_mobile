import 'package:flutter/material.dart';

const brand = Color(0xFF2563EB);
const ink = Color(0xFF182B49);
const muted = Color(0xFF52637A);
const canvas = Color(0xFFF5F7FB);
const line = Color(0xFFE3E9F2);

IconData requestIcon(String kind) => switch (kind) {
  'Cuti' => Icons.event_available_outlined,
  'Reimbursement' => Icons.receipt_long_outlined,
  'Petty Cash' => Icons.account_balance_wallet_outlined,
  'General Affair' => Icons.business_center_outlined,
  _ => Icons.more_time_outlined,
};

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Semantics(
        header: true,
        child: Text(title, style: Theme.of(context).textTheme.titleLarge),
      ),
      if (subtitle != null) ...[
        const SizedBox(height: 6),
        Text(subtitle!, style: const TextStyle(color: muted)),
      ],
    ],
  );
}

class ErrorNotice extends StatelessWidget {
  const ErrorNotice(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB42318)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB42318)),
            ),
          ),
        ],
      ),
    ),
  );
}

void notify(BuildContext context, Object message) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(message.toString())));

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) {
    final color = switch (label) {
      'Disetujui' || 'Final' || 'Hadir' => const Color(0xFF08745D),
      'Ditolak' || 'Terlambat' => const Color(0xFFB42318),
      _ => const Color(0xFF8A4B08),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        const Icon(Icons.inbox_outlined, size: 36, color: muted),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
      ],
    ),
  );
}

class DetailLine extends StatelessWidget {
  const DetailLine(this.label, this.value, {super.key});
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(label, style: const TextStyle(color: muted)),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
