import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/presentation/providers/booking_providers.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/widgets/async_state_view.dart';
import 'package:eventix/presentation/widgets/booking_confirmation_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  final String eventId;
  final int quantity;

  const BookingConfirmationScreen({
    super.key,
    required this.eventId,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intent = (eventId: eventId, quantity: quantity);
    final event = ref.watch(eventDetailProvider(eventId));
    final confirmation = ref.watch(bookingConfirmationProvider(intent));
    final savedBooking = confirmation.asData?.value;
    final confirmedBooking =
        savedBooking != null &&
            savedBooking.eventId == eventId &&
            savedBooking.quantity == quantity
        ? savedBooking
        : null;
    void submit() {
      ref
          .read(bookingConfirmationProvider(intent).notifier)
          .confirm()
          .then<void>((_) {}, onError: (Object _) {});
    }

    return PopScope(
      canPop: confirmedBooking == null,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: confirmedBooking == null,
          title: const AppText.titleMedium('Confirmar reserva'),
        ),
        body: SafeArea(
          child: AsyncStateView<Event>(
            value: event,
            onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
            builder: (value) => BookingConfirmationContent(
              event: value,
              quantity: quantity,
              booking: confirmedBooking,
              isLoading: confirmation.isLoading,
              errorMessage: bookingConfirmationErrorMessage(
                confirmation.hasError ? confirmation.error : null,
              ),
              onConfirm: submit,
              onRetry: submit,
              onBackToEvent: context.pop,
              onViewBookings: () => context.push('/bookings'),
              onGoHome: () {
                ref.invalidate(eventsProvider);
                context.go('/home');
              },
            ),
          ),
        ),
      ),
    );
  }
}
