import 'package:eventix/data/models/booking_model.dart';
import 'package:eventix/data/models/ticket_model.dart';

abstract class BookingDatasource {
  Future<BookingModel> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  });

  Future<List<BookingModel>> getBookingsByUser(String userId);

  Future<BookingModel?> getBookingById({
    required String bookingId,
    required String userId,
  });

  Future<List<TicketModel>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  });
}
