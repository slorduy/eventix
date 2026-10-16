import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:flutter/material.dart';

class BookingConfirmationContent extends StatelessWidget {
  final Event event;
  final int quantity;
  final Booking? booking;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;
  final VoidCallback onBackToEvent;
  final VoidCallback onViewBookings;
  final VoidCallback onGoHome;

  const BookingConfirmationContent({
    super.key,
    required this.event,
    required this.quantity,
    required this.booking,
    required this.isLoading,
    required this.errorMessage,
    required this.onConfirm,
    required this.onRetry,
    required this.onBackToEvent,
    required this.onViewBookings,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final insufficientAvailability = event.availableTickets < quantity;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (booking != null) ...[
          const AppBanner.success(
            title: 'Reserva confirmada',
            description: 'Tus entradas están listas en Mis reservas.',
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (errorMessage != null) ...[
          AppBanner.error(title: errorMessage!),
          const SizedBox(height: AppSpacing.md),
        ],
        if (booking == null && insufficientAvailability) ...[
          AppBanner.warning(
            title: 'No hay suficientes cupos',
            description: 'Regresa al evento y ajusta la cantidad disponible.',
            action: TextButton(
              onPressed: onBackToEvent,
              child: const Text('Volver al evento'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        BookingConfirmationSummary(event: event, quantity: quantity),
        const SizedBox(height: AppSpacing.md),
        const AppBanner.info(
          title: 'Compra simulada',
          description:
              'No se realizará ningún cobro ni se solicitarán datos de pago.',
        ),
        const SizedBox(height: AppSpacing.lg),
        BookingConfirmationActions(
          hasBooking: booking != null,
          isLoading: isLoading,
          canConfirm: !insufficientAvailability,
          hasError: errorMessage != null,
          onConfirm: onConfirm,
          onRetry: onRetry,
          onViewBookings: onViewBookings,
          onGoHome: onGoHome,
        ),
      ],
    );
  }
}

class BookingConfirmationSummary extends StatelessWidget {
  final Event event;
  final int quantity;

  const BookingConfirmationSummary({
    super.key,
    required this.event,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) => AppCard.flat(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.titleLarge(event.title),
        const SizedBox(height: AppSpacing.sm),
        AppText.bodyMedium('${event.city} · ${event.locationName}'),
        const SizedBox(height: AppSpacing.md),
        BookingSummaryRow(label: 'Entradas', value: '$quantity'),
        const SizedBox(height: AppSpacing.xs),
        BookingSummaryRow(
          label: 'Precio unitario',
          value: '${event.currencyCode} ${_formatPrice(event.price)}',
        ),
        const Divider(height: AppSpacing.lg),
        BookingSummaryRow(
          label: 'Total simulado',
          value:
              '${event.currencyCode} ${_formatPrice(event.price * quantity)}',
          emphasized: true,
        ),
      ],
    ),
  );

  static String _formatPrice(double price) => price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);
}

class BookingSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;

  const BookingSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      AppText.bodyMedium(label),
      AppText.titleMedium(
        value,
        color: emphasized ? AppColors.primary700 : null,
      ),
    ],
  );
}

class BookingConfirmationActions extends StatelessWidget {
  final bool hasBooking;
  final bool isLoading;
  final bool canConfirm;
  final bool hasError;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;
  final VoidCallback onViewBookings;
  final VoidCallback onGoHome;

  const BookingConfirmationActions({
    super.key,
    required this.hasBooking,
    required this.isLoading,
    required this.canConfirm,
    required this.hasError,
    required this.onConfirm,
    required this.onRetry,
    required this.onViewBookings,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    if (hasBooking) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton.primary(
            label: 'Ver mis reservas',
            isFullWidth: true,
            onPressed: onViewBookings,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton.outline(
            label: 'Volver al inicio',
            isFullWidth: true,
            onPressed: onGoHome,
          ),
        ],
      );
    }

    return Column(
      children: [
        AppButton.primary(
          label: 'Confirmar reserva',
          isFullWidth: true,
          isLoading: isLoading,
          onPressed: isLoading || !canConfirm ? null : onConfirm,
        ),
        if (hasError) ...[
          const SizedBox(height: AppSpacing.sm),
          AppButton.ghost(label: 'Reintentar', onPressed: onRetry),
        ],
      ],
    );
  }
}
