import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/presentation/widgets/async_state_view.dart';
import 'package:eventix/presentation/widgets/booking_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingDetailContent extends StatelessWidget {
  final Booking booking;
  final AsyncValue<List<Ticket>> tickets;
  final VoidCallback onRetryTickets;

  const BookingDetailContent({
    super.key,
    required this.booking,
    required this.tickets,
    required this.onRetryTickets,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        BookingSummaryCard(booking: booking),
        const SizedBox(height: AppSpacing.lg),
        const AppText.titleLarge('Tus entradas'),
        const SizedBox(height: AppSpacing.sm),
        AsyncStateView<List<Ticket>>(
          value: tickets,
          onRetry: onRetryTickets,
          isEmpty: (items) => items.isEmpty,
          emptyTitle: 'No hay tickets disponibles',
          emptyDescription:
              'Los tickets de esta reserva aún no están disponibles.',
          builder: (items) => Column(
            children: [
              for (final ticket in items) ...[
                BookingTicketCard(ticket: ticket),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class BookingSummaryCard extends StatelessWidget {
  final Booking booking;

  const BookingSummaryCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final event = booking.eventInfo;
    return AppCard.flat(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.titleLarge(event?.title ?? 'Evento'),
          if (event != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AppText.bodyMedium('${event.city} · ${event.locationName}'),
          ],
          const Divider(height: AppSpacing.lg),
          AppText.bodyMedium('Reserva: ${booking.id}'),
          const SizedBox(height: AppSpacing.xs),
          AppText.bodyMedium('Entradas: ${booking.quantity}'),
          const SizedBox(height: AppSpacing.xs),
          AppText.titleMedium(
            'Total: ${booking.currencyCode} ${formatBookingAmount(booking.totalAmount)}',
          ),
          const SizedBox(height: AppSpacing.xs),
          AppChip.status(label: bookingStatusLabel(booking.status)),
        ],
      ),
    );
  }
}

class BookingTicketCard extends StatelessWidget {
  final Ticket ticket;

  const BookingTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) => AppCard.outlined(
    child: Row(
      children: [
        const Icon(Icons.confirmation_number_outlined),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: AppText.titleMedium(ticket.code)),
        AppChip.status(label: ticketStatusLabel(ticket.status)),
      ],
    ),
  );
}
