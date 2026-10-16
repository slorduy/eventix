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
import 'package:go_router/go_router.dart';

class _FakeEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async => [_event()].where(filter.matches).toList();

  @override
  Future<Event?> getEventById(String eventId) async =>
      eventId == 'event-1' ? _event() : null;
}

class _FakeBookingRepository implements BookingRepository {
  final bool failConfirmation;

  const _FakeBookingRepository({required this.failConfirmation});

  @override
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    if (failConfirmation) throw Exception('private backend failure');
    final now = DateTime.utc(2026, 10, 16);
    return Booking(
      id: 'booking-1',
      userId: 'user-1',
      eventId: eventId,
      quantity: quantity,
      unitPrice: 100.0,
      totalAmount: 100.0 * quantity,
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
  testWidgets('allows back navigation before confirming the reservation', (
    tester,
  ) async {
    final router = await _pumpFlow(tester, failConfirmation: false);
    addTearDown(router.dispose);

    await tester.tap(find.text('Abrir confirmación'));
    await tester.pumpAndSettle();

    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Pantalla anterior'), findsOneWidget);
  });

  testWidgets('allows back navigation after a confirmation failure', (
    tester,
  ) async {
    final router = await _pumpFlow(tester, failConfirmation: true);
    addTearDown(router.dispose);

    await tester.tap(find.text('Abrir confirmación'));
    await tester.pumpAndSettle();
    final confirmButton = find.widgetWithText(
      OutlinedButton,
      'Confirmar reserva',
    );
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(
      find.text('No fue posible confirmar la reserva. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.byType(BackButton), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Pantalla anterior'), findsOneWidget);
  });
}

Future<GoRouter> _pumpFlow(
  WidgetTester tester, {
  required bool failConfirmation,
}) async {
  final router = GoRouter(
    initialLocation: '/previous',
    routes: [
      GoRoute(
        path: '/previous',
        builder: (context, state) => Scaffold(
          body: Column(
            children: [
              const Text('Pantalla anterior'),
              TextButton(
                onPressed: () =>
                    context.push('/events/event-1/confirmation?quantity=2'),
                child: const Text('Abrir confirmación'),
              ),
            ],
          ),
        ),
      ),
      GoRoute(
        path: '/events/:eventId/confirmation',
        builder: (context, state) => BookingConfirmationScreen(
          eventId: state.pathParameters['eventId']!,
          quantity: int.parse(state.uri.queryParameters['quantity']!),
        ),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(_FakeEventRepository()),
        bookingRepositoryProvider.overrideWithValue(
          _FakeBookingRepository(failConfirmation: failConfirmation),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Event _event() => Event(
  id: 'event-1',
  title: 'Concierto',
  description: 'Música en vivo',
  categoryId: 'category-music',
  cityId: 'city-bogota',
  category: 'Música en vivo',
  city: 'Bogotá',
  locationName: 'Teatro',
  eventDate: DateTime.utc(2026, 11, 1, 20),
  price: 100,
  currencyCode: 'COP',
  capacity: 50,
  availableTickets: 10,
);
