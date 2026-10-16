import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';

class GetBookingTicketsUsecase {
  final BookingRepository repository;

  const GetBookingTicketsUsecase({required this.repository});

  Future<List<Ticket>> call({
    required String bookingId,
    required String userId,
  }) {
    return repository.getTicketsByBooking(bookingId: bookingId, userId: userId);
  }
}
