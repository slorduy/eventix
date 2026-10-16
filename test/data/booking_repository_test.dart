import 'package:eventix/data/datasources/booking_datasource.dart';
import 'package:eventix/data/models/booking_model.dart';
import 'package:eventix/data/models/ticket_model.dart';
import 'package:eventix/data/repositories/booking_repository_impl.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingDatasource implements BookingDatasource {
  String? eventId;
  int? quantity;
  String? requestId;
  String? listedUserId;
  String? bookingId;
  String? detailUserId;
  String? ticketsBookingId;
  String? ticketsUserId;
  BookingModel? booking;
  Object? error;
  List<BookingModel> bookings = const [];
  List<TicketModel> tickets = const [];

  @override
  Future<BookingModel> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    this.eventId = eventId;
    this.quantity = quantity;
    this.requestId = requestId;
    if (error != null) throw error!;
    return booking ?? _bookingModel();
  }

  @override
  Future<List<BookingModel>> getBookingsByUser(String userId) async {
    listedUserId = userId;
    if (error != null) throw error!;
    return bookings;
  }

  @override
  Future<BookingModel?> getBookingById({
    required String bookingId,
    required String userId,
  }) async {
    this.bookingId = bookingId;
    detailUserId = userId;
    if (error != null) throw error!;
    return booking;
  }

  @override
  Future<List<TicketModel>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  }) async {
    ticketsBookingId = bookingId;
    ticketsUserId = userId;
    if (error != null) throw error!;
    return tickets;
  }
}

void main() {
  test('confirm forwards the idempotency key and maps the result', () async {
    final datasource = _FakeBookingDatasource();

    final result = await BookingRepositoryImpl(
      datasource: datasource,
    ).confirmBooking(eventId: 'event-1', quantity: 2, requestId: 'request-1');

    expect(datasource.eventId, 'event-1');
    expect(datasource.quantity, 2);
    expect(datasource.requestId, 'request-1');
    expect(result.id, 'booking-1');
  });

  test('lists reservations scoped by the requested user ID', () async {
    final datasource = _FakeBookingDatasource()..bookings = [_bookingModel()];

    final result = await BookingRepositoryImpl(datasource: datasource)
        .getBookingsByUser('user-1');

    expect(datasource.listedUserId, 'user-1');
    expect(result.single.userId, 'user-1');
  });

  test('loads booking and tickets with both ownership filters', () async {
    final datasource = _FakeBookingDatasource()
      ..booking = _bookingModel()
      ..tickets = [_ticketModel()];
    final repository = BookingRepositoryImpl(datasource: datasource);

    final booking = await repository.getBookingById(
      bookingId: 'booking-1',
      userId: 'user-1',
    );
    final tickets = await repository.getTicketsByBooking(
      bookingId: 'booking-1',
      userId: 'user-1',
    );

    expect(booking?.id, 'booking-1');
    expect(tickets.single.bookingId, 'booking-1');
    expect(datasource.bookingId, 'booking-1');
    expect(datasource.detailUserId, 'user-1');
    expect(datasource.ticketsBookingId, 'booking-1');
    expect(datasource.ticketsUserId, 'user-1');
  });

  test('maps backend details to a safe exception', () async {
    final datasource = _FakeBookingDatasource()
      ..error = Exception('private SQL detail');

    await expectLater(
      BookingRepositoryImpl(datasource: datasource).getBookingsByUser('user-1'),
      throwsA(
        isA<BookingRepositoryException>().having(
          (error) => error.userMessage,
          'userMessage',
          contains('Inténtalo de nuevo'),
        ),
      ),
    );
  });
}

BookingModel _bookingModel() {
  final date = DateTime.utc(2026, 10, 15);
  return BookingModel(
    id: 'booking-1',
    userId: 'user-1',
    eventId: 'event-1',
    quantity: 2,
    unitPrice: 10,
    totalAmount: 20,
    currencyCode: 'COP',
    status: BookingStatus.confirmed,
    createdAt: date,
    confirmedAt: date,
  );
}

TicketModel _ticketModel() => TicketModel(
  id: 'ticket-1',
  bookingId: 'booking-1',
  code: 'CODE-1',
  status: TicketStatus.valid,
  issuedAt: DateTime.utc(2026, 10, 15),
);
