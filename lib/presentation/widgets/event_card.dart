import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/presentation/widgets/event_image_placeholder.dart';
import 'package:flutter/material.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = event.eventDate.toLocal();
    final availableLabel = event.availableTickets == 1
        ? '1 cupo disponible'
        : '${event.availableTickets} cupos disponibles';

    return AppCard.elevated(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                event.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const EventImagePlaceholder(),
              ),
            )
          else
            const EventImagePlaceholder(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppChip.status(label: event.category),
                const SizedBox(height: AppSpacing.sm),
                AppText.titleLarge(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText.bodyMedium(
                  '${event.city} · ${event.locationName}',
                  color: AppColors.neutral600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText.bodyMedium(_formatDate(date)),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.titleMedium(
                      '${event.currencyCode} ${_formatPrice(event.price)}',
                      color: AppColors.primary700,
                    ),
                    AppText.bodySmall(
                      availableLabel,
                      color: event.availableTickets == 0
                          ? AppColors.error
                          : AppColors.neutral600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatPrice(double price) => price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);

  static String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year} · $hour:$minute';
  }
}
