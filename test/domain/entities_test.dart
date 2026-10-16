import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Booking', () {
    test('stores UUID-style IDs as strings and a confirmed price snapshot', () {
      final createdAt = DateTime.utc(2026, 10, 15);
      final booking = Booking(
        id: 'booking-uuid',
        userId: 'user-uuid',
        eventId: 'event-uuid',
        quantity: 2,
        unitPrice: 25.5,
        totalAmount: 51,
        currencyCode: 'USD',
        createdAt: createdAt,
        confirmedAt: createdAt,
      );

      expect(booking.userId, 'user-uuid');
      expect(booking.eventId, 'event-uuid');
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.totalAmount, booking.unitPrice * booking.quantity);
    });
  });

  group('Ticket', () {
    test('stores its booking relation, status, and issue date', () {
      final issuedAt = DateTime.utc(2026, 10, 15);
      final ticket = Ticket(
        id: 'ticket-uuid',
        bookingId: 'booking-uuid',
        code: 'TICKET-001',
        issuedAt: issuedAt,
      );

      expect(ticket.bookingId, 'booking-uuid');
      expect(ticket.status, TicketStatus.valid);
      expect(ticket.date, issuedAt);
    });
  });
}
