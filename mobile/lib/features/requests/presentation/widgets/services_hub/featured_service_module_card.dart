import 'package:flutter/material.dart';
import 'package:uicons/uicons.dart';

class FeaturedServiceModuleCard extends StatelessWidget {
  final String title;
  final String metricTag;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final Color accentColor;

  const FeaturedServiceModuleCard({
    super.key,
    required this.title,
    required this.metricTag,
    required this.description,
    required this.icon,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFF1F5F9),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFFF5F5F5),
                blurRadius: 9,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFCCFBF1),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  size: 22,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: const Color(0xFFA7F3D0),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            metricTag,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: -0.1,
                            ),
                            softWrap: false,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  UIcons.regularRounded.angle_small_right,
                  size: 18,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
