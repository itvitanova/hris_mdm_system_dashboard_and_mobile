import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';

String requestDateLabel(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final local = value.length > 10 ? date.toLocal() : date;
  final base =
      '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  return value.length > 10
      ? '$base, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}'
      : base;
}

/// Helper formatting and clean-up functions for request detail views
class DetailFormatters {
  static String getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'HR';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  static String cleanDescriptionText(String rawDesc) {
    if (rawDesc.isEmpty) return '';
    var desc = rawDesc;
    final metadataMatch = RegExp(r'\n\n\[(.*?)\]$').firstMatch(desc);
    if (metadataMatch != null) {
      final metaContent = metadataMatch.group(1)!;
      final parts = metaContent
          .split(' · ')
          .where((part) {
            final p = part.trim().toLowerCase();
            return !p.startsWith('lampiran:') && !p.startsWith('jenis izin:');
          })
          .toList();
      final baseDesc = desc.substring(0, metadataMatch.start).trim();
      if (parts.isNotEmpty) {
        desc = baseDesc.isNotEmpty
            ? '$baseDesc\n\n[${parts.join(' · ')}]'
            : '[${parts.join(' · ')}]';
      } else {
        desc = baseDesc;
      }
    } else {
      desc = desc.replaceAll(
          RegExp(r'\[?Lampiran:\s*[^\]\n]+\]?', caseSensitive: false), '');
      desc = desc.replaceAll(
          RegExp(r'\[?Jenis Izin:\s*[^\]\n]+\]?', caseSensitive: false), '');
    }
    return desc.trim();
  }

  static String cleanItemDescription(String desc) {
    if (desc.isEmpty) return '—';
    var cleaned = desc.trim();

    cleaned = cleaned.replaceAll(
        RegExp(r'\s*·\s*(@?Rp\.?\s*)?[\d.,]+(?=\s*\))', caseSensitive: false),
        '');
    cleaned = cleaned.replaceAll(
        RegExp(r'\s*\((@?Rp\.?\s*)?[\d.,]+\)', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(
        RegExp(r'\s*·\s*(@?Rp\.?\s*)?[\d.,]+$', caseSensitive: false), '');
    cleaned = cleaned.trim();

    final singleParenMatch = RegExp(r'^\(([^()]+)\)$').firstMatch(cleaned);
    if (singleParenMatch != null) {
      cleaned = singleParenMatch.group(1)!.trim();
    }

    final duplicateMatch = RegExp(r'^(.*?)\s*\(\s*(.*?)\s*\)$',
            caseSensitive: false)
        .firstMatch(cleaned);
    if (duplicateMatch != null) {
      final mainText = duplicateMatch.group(1)!.trim();
      final insideParen = duplicateMatch.group(2)!.trim();
      if (mainText.toLowerCase() == insideParen.toLowerCase()) {
        cleaned = mainText;
      }
    }

    return cleaned.isNotEmpty ? cleaned : '—';
  }

  static IconData getExpenseCategoryIcon(String category) {
    final c = category.toLowerCase();
    if (c.contains('trans') ||
        c.contains('parkir') ||
        c.contains('bensin') ||
        c.contains('tol') ||
        c.contains('ojek') ||
        c.contains('taksi') ||
        c.contains('kendaraan')) {
      return UIcons.regularRounded.car;
    }
    if (c.contains('makan') ||
        c.contains('konsumsi') ||
        c.contains('kuliner') ||
        c.contains('snack') ||
        c.contains('food')) {
      return UIcons.regularRounded.restaurant;
    }
    if (c.contains('hotel') || c.contains('inap') || c.contains('lodging')) {
      return UIcons.regularRounded.bed;
    }
    if (c.contains('medis') ||
        c.contains('obat') ||
        c.contains('dokter') ||
        c.contains('klinik') ||
        c.contains('kesehatan') ||
        c.contains('claim')) {
      return UIcons.regularRounded.stethoscope;
    }
    if (c.contains('atk') ||
        c.contains('kantor') ||
        c.contains('operasional') ||
        c.contains('logistik') ||
        c.contains('barang')) {
      return UIcons.regularRounded.boxes;
    }
    if (c.contains('pesawat') ||
        c.contains('terbang') ||
        c.contains('flight')) {
      return UIcons.regularRounded.plane;
    }
    if (c.contains('kereta') ||
        c.contains('train') ||
        c.contains('krl') ||
        c.contains('mrt')) {
      return UIcons.regularRounded.train;
    }
    return UIcons.regularRounded.receipt;
  }

  static bool isStatusRevision(dynamic status) {
    final s = (status ?? '').toString().toLowerCase().replaceAll(' ', '');
    return s == 'perlurevisi' || s == 'revisi' || s == 'needs_revision';
  }
}
