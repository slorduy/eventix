import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/widgets/event_image_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailContent extends ConsumerWidget {
  final Event event;

  const EventDetailContent({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = this.event;
    final available = event.availableTickets;
    final selectedQuantity = ref.watch(eventQuantityProvider(event.id));
    final quantity = available == 0
        ? 0
        : selectedQuantity.clamp(1, available).toInt();
    final quantityController = ref.read(
      eventQuantityProvider(event.id).notifier,
    );

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        EventHeroImage(imageUrl: event.imageUrl),
        const SizedBox(height: AppSpacing.md),
        AppChip.status(label: event.category),
        const SizedBox(height: AppSpacing.sm),
        AppText.headlineMedium(event.title),
        const SizedBox(height: AppSpacing.md),
        EventLocationCard(event: event),
        const SizedBox(height: AppSpacing.md),
        const AppText.titleMedium('Sobre el evento'),
        const SizedBox(height: AppSpacing.xs),
        AppText.bodyMedium(event.description),
        const SizedBox(height: AppSpacing.lg),
        EventTicketSelection(
          event: event,
          quantity: quantity,
          onDecrease: quantity > 1
              ? () => quantityController.decrease(available)
              : null,
          onIncrease: quantity < available
              ? () => quantityController.increase(available)
              : null,
          onContinue: available == 0
              ? null
              : () => context.push(
                  '/events/${event.id}/confirmation?quantity=$quantity',
                ),
        ),
      ],
    );
  }
}

class EventHeroImage extends StatelessWidget {
  final String? imageUrl;

  const EventHeroImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const EventImagePlaceholder(height: 240);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl!,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const EventImagePlaceholder(height: 240),
      ),
    );
  }
}

class EventLocationCard extends StatelessWidget {
  final Event event;

  const EventLocationCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) => AppCard.flat(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EventDetailRow(
          icon: Icons.calendar_month_outlined,
          label: _formatDate(event.eventDate.toLocal()),
        ),
        const SizedBox(height: AppSpacing.sm),
        EventDetailRow(
          icon: Icons.location_on_outlined,
          label: '${event.locationName}, ${event.city}',
        ),
        if (event.address?.isNotEmpty ?? false) ...[
          const SizedBox(height: AppSpacing.xs),
          EventDetailRow(icon: Icons.map_outlined, label: event.address!),
        ],
      ],
    ),
  );

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} · '
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class EventTicketSelection extends StatelessWidget {
  final Event event;
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback? onContinue;

  const EventTicketSelection({
    super.key,
    required this.event,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) => AppCard.outlined(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.titleMedium(
          '${event.currencyCode} ${_formatPrice(event.price)} por entrada',
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText.bodySmall('${event.availableTickets} cupos disponibles'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Expanded(child: AppText.labelLarge('Cantidad')),
            IconButton(
              tooltip: 'Quitar una entrada',
              onPressed: onDecrease,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            AppText.titleMedium('$quantity'),
            IconButton(
              tooltip: 'Agregar una entrada',
              onPressed: onIncrease,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        if (quantity > 0) ...[
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText.labelLarge('Total'),
              AppText.titleMedium(
                '${event.currencyCode} ${_formatPrice(event.price * quantity)}',
              ),
            ],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        AppButton.primary(
          label: event.availableTickets == 0
              ? 'Sin cupos disponibles'
              : 'Continuar',
          isFullWidth: true,
          onPressed: onContinue,
        ),
      ],
    ),
  );

  static String _formatPrice(double price) => price == price.roundToDouble()
      ? price.toStringAsFixed(0)
      : price.toStringAsFixed(2);
}

class EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const EventDetailRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 20, color: AppColors.primary700),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: AppText.bodyMedium(label)),
    ],
  );
}
