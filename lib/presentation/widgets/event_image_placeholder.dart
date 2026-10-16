import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';

class EventImagePlaceholder extends StatelessWidget {
  final double height;

  const EventImagePlaceholder({super.key, this.height = 180});

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: AppColors.neutral200,
      borderRadius: BorderRadius.circular(12),
    ),
    alignment: Alignment.center,
    child: const Icon(
      Icons.event_outlined,
      size: 56,
      color: AppColors.neutral600,
    ),
  );
}
