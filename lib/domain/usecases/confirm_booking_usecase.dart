import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';

class ConfirmBookingUsecase {
  final BookingRepository repository;

  const ConfirmBookingUsecase({required this.repository});

  Future<Booking> call({
    required String eventId,
    required int quantity,
    required String requestId,
  }) {
    if (eventId.trim().isEmpty) {
      throw ArgumentError.value(eventId, 'eventId', 'Must not be empty');
    }
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'Must be at least 1');
    }
    if (requestId.trim().isEmpty) {
      throw ArgumentError.value(requestId, 'requestId', 'Must not be empty');
    }

    return repository.confirmBooking(
      eventId: eventId,
      quantity: quantity,
      requestId: requestId,
    );
  }
}
