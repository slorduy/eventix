import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';

abstract class BookingRepository {
  /// Confirms a simulated purchase. Ownership, price, and ticket codes are
  /// determined by the authenticated backend session, not by the caller.
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  });

  Future<List<Booking>> getBookingsByUser(String userId);

  Future<Booking?> getBookingById({
    required String bookingId,
    required String userId,
  });

  Future<List<Ticket>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  });
}
