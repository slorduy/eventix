import 'package:eventix/domain/entities/event.dart';

enum BookingStatus { confirmed, cancelled }

class Booking {
  final String id;
  final String userId;
  final String eventId;
  final Event? eventInfo;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String currencyCode;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime confirmedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.eventId,
    this.eventInfo,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.currencyCode,
    this.status = BookingStatus.confirmed,
    required this.createdAt,
    required this.confirmedAt,
  });
}
