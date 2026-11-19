import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uicons/uicons.dart';

class FaceScanFeedbackSection extends StatelessWidget {
  const FaceScanFeedbackSection({
    super.key,
    required this.error,
    required this.hint,
    required this.color,
    required this.capturing,
    required this.progress,
    required this.onRetry,
  });

  final String? error;
  final String hint;
  final Color color;
  final bool capturing;
  final double progress;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (error == null) {
      return Column(
        children: [
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: capturing ? null : progress,
            color: Colors.tealAccent,
            backgroundColor: Colors.white12,
            borderRadius: BorderRadius.circular(8),
            minHeight: 5,
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFFFCA5A5)),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onRetry,
          icon: Icon(UIcons.regularRounded.refresh),
          label: const Text('Pindai ulang'),
        ),
        TextButton(
          onPressed: Geolocator.openAppSettings,
          child: const Text('Buka pengaturan aplikasi'),
        ),
      ],
    );
  }
}
