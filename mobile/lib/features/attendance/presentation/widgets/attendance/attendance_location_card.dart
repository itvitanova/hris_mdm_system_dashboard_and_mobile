import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/widgets/core_widgets.dart';
import 'package:mdm_hris/core/workspace.dart';

class AttendanceLocationCard extends StatelessWidget {
  const AttendanceLocationCard({
    super.key,
    required this.policy,
    required this.position,
    required this.locating,
    required this.safe,
    required this.distance,
    required this.error,
    required this.anywhere,
    required this.onOpenMap,
  });

  final Json policy;
  final Position? position;
  final bool locating;
  final bool safe;
  final double? distance;
  final String? error;
  final bool anywhere;
  final void Function(double lat, double lng) onOpenMap;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(UIcons.regularRounded.marker, color: brand, size: 30),
          const SizedBox(height: 12),
          Text(
            text(policy, 'name', 'Lokasi belum ditentukan'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Jadwal ${text(policy, "workStart")} – ${text(policy, "workEnd", "jam pulang belum diatur")}',
            style: const TextStyle(
              color: muted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            anywhere
                ? 'Anda diizinkan absensi dari lokasi mana saja. GPS aktual masuk dan keluar tetap dicatat.'
                : 'Lokasi diperiksa otomatis. Absensi hanya diterima dalam radius ${number(policy, 'radius').round()} meter dari lokasi penugasan.',
          ),
          const SizedBox(height: 16),
          if (locating) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              position != null && position!.accuracy > 50
                  ? 'Meningkatkan akurasi GPS… Tunggu sebentar di dekat jendela atau area terbuka.'
                  : 'Memperbarui lokasi GPS…',
            ),
          ],
          if (distance != null)
            Text(
              'Jarak ${distance!.round()} m • akurasi ±${position!.accuracy.round()} m',
              style: TextStyle(
                color: safe
                    ? const Color(0xFF08745D)
                    : const Color(0xFFB42318),
              ),
            ),
          Text(
            safe
                ? (anywhere
                    ? 'GPS siap. Izin absensi dari lokasi mana saja aktif.'
                    : 'Anda berada di area kantor.')
                : 'Menunggu lokasi yang memenuhi syarat.',
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: ErrorNotice(error!),
            ),
          if (policy['latitude'] is num &&
              policy['longitude'] is num &&
              number(policy, 'radius') > 0)
            TextButton.icon(
              onPressed: () => onOpenMap(
                number(policy, 'latitude'),
                number(policy, 'longitude'),
              ),
              icon: Icon(UIcons.regularRounded.marker),
              label: const Text('Peta lokasi penugasan'),
            ),
          if (position != null)
            TextButton.icon(
              onPressed: () => onOpenMap(
                position!.latitude,
                position!.longitude,
              ),
              icon: Icon(UIcons.regularRounded.marker),
              label: const Text('Peta lokasi saya'),
            ),
          if (error != null)
            TextButton(
              onPressed: Geolocator.openAppSettings,
              child: const Text('Pengaturan izin lokasi'),
            ),
        ],
      ),
    );
  }
}
