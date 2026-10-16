import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';
import 'package:eventix/data/repositories/booking_repository_impl.dart';
import 'package:eventix/presentation/providers/booking_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RetryBookingRepository implements BookingRepository {
  final requestIds = <String>[];
  var attempts = 0;

  @override
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    requestIds.add(requestId);
    attempts++;
    if (attempts == 1) {
      throw const BookingRepositoryException('Temporary error');
    }
    final now = DateTime.utc(2026, 10, 15);
    return Booking(
      id: 'booking-1',
      userId: 'user-1',
      eventId: eventId,
      quantity: quantity,
      unitPrice: 10,
      totalAmount: quantity * 10,
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
  test('reuses the idempotency key after a failed attempt', () async {
    final repository = _RetryBookingRepository();
    final container = ProviderContainer(
      overrides: [bookingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    const intent = (eventId: 'event-1', quantity: 2);
    final controller = container.read(
      bookingConfirmationProvider(intent).notifier,
    );

    await expectLater(
      controller.confirm(),
      throwsA(isA<BookingRepositoryException>()),
    );
    final firstRequestId = repository.requestIds.single;

    final booking = await controller.confirm();

    expect(repository.requestIds, [firstRequestId, firstRequestId]);
    expect(booking.id, 'booking-1');
    expect(
      container.read(bookingConfirmationProvider(intent)).value?.id,
      'booking-1',
    );
  });
}
