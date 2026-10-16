import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/presentation/widgets/booking_display.dart';
import 'package:flutter/material.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const BookingCard({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final event = booking.eventInfo;
    final date = event?.eventDate.toLocal();

    return AppCard.outlined(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText.titleMedium(
                  event?.title ?? 'Evento',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppChip.status(label: bookingStatusLabel(booking.status)),
            ],
          ),
          if (event != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppText.bodyMedium('${event.city} · ${event.locationName}'),
          ],
          if (date != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppText.bodySmall(formatBookingDate(date)),
          ],
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.bodyMedium('${booking.quantity} entradas'),
              AppText.titleMedium(
                '${booking.currencyCode} ${formatBookingAmount(booking.totalAmount)}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
