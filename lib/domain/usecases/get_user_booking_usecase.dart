import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';

class GetUserBookingUsecase {
  final BookingRepository repository;

  GetUserBookingUsecase({required this.repository});

  Future<List<Booking>> call(String userId) {
    return repository.getBookingsByUser(userId);
  }
}
