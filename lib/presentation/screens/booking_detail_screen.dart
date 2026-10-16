import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/providers/booking_providers.dart';
import 'package:eventix/presentation/widgets/async_state_view.dart';
import 'package:eventix/presentation/widgets/booking_detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAuthUserIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: AppEmptyState.error(
          title: 'Sesión requerida',
          description: 'Inicia sesión para consultar esta reserva.',
        ),
      );
    }

    final params = (bookingId: bookingId, userId: userId);
    final booking = ref.watch(bookingDetailProvider(params));

    return Scaffold(
      appBar: AppBar(title: const AppText.titleMedium('Detalle de reserva')),
      body: AsyncStateView<Booking?>(
        value: booking,
        onRetry: () => ref.invalidate(bookingDetailProvider(params)),
        isEmpty: (value) => value == null,
        emptyTitle: 'Reserva no encontrada',
        emptyDescription: 'No encontramos esta reserva en tu cuenta.',
        builder: (value) => BookingDetailContent(
          booking: value!,
          tickets: ref.watch(bookingTicketsProvider(params)),
          onRetryTickets: () => ref.invalidate(bookingTicketsProvider(params)),
        ),
      ),
    );
  }
}
