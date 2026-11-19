import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mdm_hris/core/api_client.dart';

class AttendanceMapLauncher {
  static Future<void> openMap({
    required BuildContext context,
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    });
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw ApiException('Google Maps tidak dapat dibuka.');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google Maps tidak dapat dibuka.')),
        );
      }
    }
  }
}
