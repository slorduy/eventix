import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:eventix/presentation/providers/booking_providers.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/screens/booking_confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async => [_event()];

  @override
  Future<Event?> getEventById(String eventId) async =>
      eventId == 'event-1' ? _event() : null;
}

class _FakeBookingRepository implements BookingRepository {
  var confirmCalls = 0;

  @override
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    confirmCalls++;
    final now = DateTime.utc(2026, 10, 15);
    return Booking(
      id: 'booking-1',
      userId: 'user-1',
      eventId: eventId,
      quantity: quantity,
      unitPrice: 100,
      totalAmount: quantity * 100,
      currencyCode: 'COP',
      createdAt: now,
      confirmedAt: now,
    );
  }

  @override
  Future<List<Booking>> getBookingsByUser(String userId) async => const [];

  @override
  Future<Booking?> getBookingById({
    required String bookingId,
    required String userId,
  }) async => null;

  @override
  Future<List<Ticket>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  }) async => const [];
}

void main() {
  testWidgets('confirms a simulated reservation and shows success', (
    tester,
  ) async {
    final bookingRepository = _FakeBookingRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(_FakeEventRepository()),
          bookingRepositoryProvider.overrideWithValue(bookingRepository),
        ],
        child: const MaterialApp(
          home: BookingConfirmationScreen(eventId: 'event-1', quantity: 2),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Compra simulada'), findsOneWidget);
    expect(
      find.text(
        'No se realizará ningún cobro ni se solicitarán datos de pago.',
      ),
      findsOneWidget,
    );
    expect(find.text('COP 200'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Confirmar reserva'));
    await tester.pumpAndSettle();

    expect(bookingRepository.confirmCalls, 1);
    expect(find.text('Reserva confirmada'), findsOneWidget);
    expect(find.text('Ver mis reservas'), findsOneWidget);
    expect(find.text('Volver al inicio'), findsOneWidget);
  });
}

Event _event() => Event(
  id: 'event-1',
  title: 'Concierto',
  description: 'Música en vivo',
  categoryId: 'category-music',
  cityId: 'city-bogota',
  category: 'Music',
  city: 'Bogotá',
  locationName: 'Teatro',
  eventDate: DateTime.utc(2026, 11, 1, 20),
  price: 100,
  currencyCode: 'COP',
  capacity: 100,
  availableTickets: 10,
);
