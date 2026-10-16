import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/providers/booking_providers.dart';
import 'package:eventix/presentation/screens/booking_detail_screen.dart';
import 'package:eventix/presentation/screens/my_bookings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeBookingRepository implements BookingRepository {
  final booking = _booking();
  final ticket = _ticket();

  @override
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async => booking;

  @override
  Future<List<Booking>> getBookingsByUser(String userId) async =>
      userId == 'user-1' ? [booking] : const [];

  @override
  Future<Booking?> getBookingById({
    required String bookingId,
    required String userId,
  }) async =>
      bookingId == booking.id && userId == booking.userId ? booking : null;

  @override
  Future<List<Ticket>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  }) async =>
      bookingId == booking.id && userId == booking.userId ? [ticket] : const [];
}

void main() {
  testWidgets('lists the authenticated user’s bookings', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAuthUserIdProvider.overrideWithValue('user-1'),
          bookingRepositoryProvider.overrideWithValue(_FakeBookingRepository()),
        ],
        child: const MaterialApp(home: MyBookingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mis reservas'), findsOneWidget);
    expect(find.text('Concierto'), findsOneWidget);
    expect(find.text('2 entradas'), findsOneWidget);
    expect(find.text('COP 200'), findsOneWidget);
  });

  testWidgets('shows the booking and its own ticket codes', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAuthUserIdProvider.overrideWithValue('user-1'),
          bookingRepositoryProvider.overrideWithValue(_FakeBookingRepository()),
        ],
        child: const MaterialApp(
          home: BookingDetailScreen(bookingId: 'booking-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Concierto'), findsOneWidget);
    expect(find.text('TICKET-1'), findsOneWidget);
    expect(find.text('Válido'), findsOneWidget);
  });

  testWidgets('returns from my bookings to the previous screen', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => Scaffold(
            body: TextButton(
              onPressed: () => context.push('/bookings'),
              child: const Text('Abrir reservas'),
            ),
          ),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => const MyBookingsScreen(),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAuthUserIdProvider.overrideWithValue('user-1'),
          bookingRepositoryProvider.overrideWithValue(_FakeBookingRepository()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir reservas'));
    await tester.pumpAndSettle();

    expect(find.text('Mis reservas'), findsOneWidget);
    await tester.tap(find.byTooltip('Volver'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir reservas'), findsOneWidget);
  });
}

Booking _booking() {
  final now = DateTime.utc(2026, 10, 15);
  return Booking(
    id: 'booking-1',
    userId: 'user-1',
    eventId: 'event-1',
    eventInfo: _event(),
    quantity: 2,
    unitPrice: 100,
    totalAmount: 200,
    currencyCode: 'COP',
    createdAt: now,
    confirmedAt: now,
  );
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
  availableTickets: 20,
);

Ticket _ticket() => Ticket(
  id: 'ticket-1',
  bookingId: 'booking-1',
  code: 'TICKET-1',
  issuedAt: DateTime.utc(2026, 10, 15),
);
