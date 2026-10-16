import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';
import 'package:eventix/domain/usecases/confirm_booking_usecase.dart';
import 'package:eventix/domain/usecases/get_booking_detail_usecase.dart';
import 'package:eventix/domain/usecases/get_booking_tickets_usecase.dart';
import 'package:eventix/domain/usecases/get_user_booking_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingRepository implements BookingRepository {
  String? confirmedEventId;
  int? confirmedQuantity;
  String? confirmedRequestId;
  String? listedUserId;
  String? requestedBookingId;
  String? requestedDetailUserId;
  String? requestedTicketsBookingId;
  String? requestedTicketsUserId;
  final bookings = <Booking>[];
  final tickets = <Ticket>[];

  @override
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    confirmedEventId = eventId;
    confirmedQuantity = quantity;
    confirmedRequestId = requestId;
    return _sampleBooking();
  }

  @override
  Future<List<Booking>> getBookingsByUser(String userId) async {
    listedUserId = userId;
    return bookings;
  }

  @override
  Future<Booking?> getBookingById({
    required String bookingId,
    required String userId,
  }) async {
    requestedBookingId = bookingId;
    requestedDetailUserId = userId;
    return bookings.isEmpty ? null : bookings.first;
  }

  @override
  Future<List<Ticket>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  }) async {
    requestedTicketsBookingId = bookingId;
    requestedTicketsUserId = userId;
    return tickets;
  }
}

void main() {
  test('ConfirmBookingUsecase forwards event and quantity', () async {
    final repository = _FakeBookingRepository();

    await ConfirmBookingUsecase(repository: repository)(
      eventId: 'event-uuid',
      quantity: 2,
      requestId: 'request-uuid',
    );

    expect(repository.confirmedEventId, 'event-uuid');
    expect(repository.confirmedQuantity, 2);
    expect(repository.confirmedRequestId, 'request-uuid');
  });

  test(
    'ConfirmBookingUsecase rejects invalid input before repository call',
    () {
      final repository = _FakeBookingRepository();
      final usecase = ConfirmBookingUsecase(repository: repository);

      expect(
        () => usecase(
          eventId: 'event-uuid',
          quantity: 0,
          requestId: 'request-uuid',
        ),
        throwsArgumentError,
      );
      expect(repository.confirmedEventId, isNull);
    },
  );

  test('GetUserBookingUsecase forwards UUID string', () async {
    final repository = _FakeBookingRepository();

    await GetUserBookingUsecase(repository: repository)('user-uuid');

    expect(repository.listedUserId, 'user-uuid');
  });

  test(
    'detail and ticket usecases scope queries to booking and user IDs',
    () async {
      final repository = _FakeBookingRepository();

      await GetBookingDetailUsecase(repository: repository)(
        bookingId: 'booking-uuid',
        userId: 'user-uuid',
      );
      await GetBookingTicketsUsecase(repository: repository)(
        bookingId: 'booking-uuid',
        userId: 'user-uuid',
      );

      expect(repository.requestedBookingId, 'booking-uuid');
      expect(repository.requestedDetailUserId, 'user-uuid');
      expect(repository.requestedTicketsBookingId, 'booking-uuid');
      expect(repository.requestedTicketsUserId, 'user-uuid');
    },
  );
}

Booking _sampleBooking() {
  final now = DateTime.utc(2026, 10, 15);
  return Booking(
    id: 'booking-uuid',
    userId: 'user-uuid',
    eventId: 'event-uuid',
    quantity: 2,
    unitPrice: 10,
    totalAmount: 20,
    currencyCode: 'COP',
    createdAt: now,
    confirmedAt: now,
  );
}
