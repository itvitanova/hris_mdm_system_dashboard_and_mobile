import 'package:flutter/material.dart';

/// Widget Kartu Statistik Modul (2x2 Grid Korporat)
class ModuleStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color accentColor;

  const ModuleStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.accentColor = const Color(0xFF0D9488),
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Corporate Teal Squircle + Clean Vector Outline Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA), // Frosted Soft Mint Teal
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFCCFBF1),
                width: 1.2,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 22,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 9),

          // 2. Numeric Value & Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                    height: 1.1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9.8,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFF5F5F5),
            blurRadius: 9,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(10),
                splashColor: const Color(0xFF0D9488).withValues(alpha: 0.12),
                highlightColor: const Color(0xFF0D9488).withValues(alpha: 0.05),
                child: cardContent,
              ),
            )
          : cardContent,
    );
  }
}
