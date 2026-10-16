import 'package:eventix/data/models/booking_model.dart';
import 'package:eventix/data/models/ticket_model.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps a booking row and its event relation', () {
    final model = BookingModel.fromJson({
      'id': 'booking-1',
      'user_id': 'user-1',
      'event_id': 'event-1',
      'quantity': 2,
      'unit_price': 120.5,
      'total_amount': 241,
      'currency_code': 'COP',
      'status': 'confirmed',
      'created_at': '2026-10-15T12:00:00.000Z',
      'confirmed_at': '2026-10-15T12:00:00.000Z',
      'event': {
        'id': 'event-1',
        'title': 'Concierto',
        'description': 'En vivo',
        'category_id': 'category-1',
        'city_id': 'city-1',
        'category_ref': {'id': 'category-1', 'name': 'Music'},
        'city_ref': {'id': 'city-1', 'name': 'Bogotá'},
        'location_name': 'Teatro',
        'event_date': '2026-11-01T20:00:00.000Z',
        'price': 120.5,
        'currency_code': 'COP',
        'capacity': 100,
        'is_published': true,
      },
    });

    final booking = model.toEntity();

    expect(booking.id, 'booking-1');
    expect(booking.userId, 'user-1');
    expect(booking.eventId, 'event-1');
    expect(booking.status, BookingStatus.confirmed);
    expect(booking.eventInfo?.title, 'Concierto');
  });

  test('maps issued ticket fields and legacy purchase date fallback', () {
    final model = TicketModel.fromJson({
      'id': 'ticket-1',
      'booking_id': 'booking-1',
      'ticket_code': 'CODE-1',
      'status': 'valid',
      'purchase_date': '2026-10-15T12:00:00.000Z',
    });

    final ticket = model.toEntity();

    expect(ticket.bookingId, 'booking-1');
    expect(ticket.code, 'CODE-1');
    expect(ticket.status, TicketStatus.valid);
    expect(ticket.issuedAt, DateTime.utc(2026, 10, 15, 12));
  });
}
