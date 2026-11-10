import 'package:flutter/material.dart';

/// Widget Kartu Statistik Modul (2x2 Grid Korporat Simetris)
/// Dirancang seragam, proporsional, dan simetris persis dengan kartu statistik dashboard.
class ModuleStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? title;
  final String? subTitle;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color accentColor;

  const ModuleStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.title,
    this.subTitle,
    this.isSelected = false,
    this.onTap,
    this.accentColor = const Color(0xFF0F766E),
  });

  @override
  Widget build(BuildContext context) {
    final displayTitle = title ?? label;
    final displaySub = subTitle ?? 'status';

    final cardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Baris Atas: Icon 32x32 + Title & Subtitle
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFCCFBF1)
                      : const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF99F6E4)
                        : const Color(0xFFCCFBF1),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 16,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.15,
                          color: isSelected
                              ? const Color(0xFF0F766E)
                              : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displaySub,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 2. Baris Bawah: Angka/Kuota Proporsional + Label
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                    height: 1.15,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0F766E)
              : const Color(0xFFF1F5F9),
          width: isSelected ? 1.4 : 1.0,
        ),
        boxShadow: isSelected
            ? const [
                BoxShadow(
                  color: Color(0x180F766E),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ]
            : const [
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
                splashColor: const Color(0xFF0F766E).withValues(alpha: 0.12),
                highlightColor: const Color(0xFF0F766E).withValues(alpha: 0.05),
                child: cardContent,
              ),
            )
          : cardContent,
    );
  }
}
