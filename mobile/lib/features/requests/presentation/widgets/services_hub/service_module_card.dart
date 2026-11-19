import 'package:flutter/material.dart';
import 'featured_service_module_card.dart';
import 'standard_service_module_card.dart';

export 'featured_service_module_card.dart';
export 'standard_service_module_card.dart';

/// Card Modul Layanan pada Katalog Hub Layanan Mandiri
class ServiceModuleCard extends StatelessWidget {
  final String title;
  final String metricTag;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;
  final bool isFeatured;

  const ServiceModuleCard({
    super.key,
    required this.title,
    required this.metricTag,
    required this.description,
    required this.icon,
    required this.onTap,
    this.accentColor = const Color(0xFF0F766E),
    this.isFeatured = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFeatured) {
      return FeaturedServiceModuleCard(
        title: title,
        metricTag: metricTag,
        description: description,
        icon: icon,
        onTap: onTap,
        accentColor: accentColor,
      );
    }

    return StandardServiceModuleCard(
      title: title,
      metricTag: metricTag,
      description: description,
      icon: icon,
      onTap: onTap,
      accentColor: accentColor,
    );
  }
}
