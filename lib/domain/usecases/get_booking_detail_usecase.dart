import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';

class GetBookingDetailUsecase {
  final BookingRepository repository;

  const GetBookingDetailUsecase({required this.repository});

  Future<Booking?> call({required String bookingId, required String userId}) {
    return repository.getBookingById(bookingId: bookingId, userId: userId);
  }
}
