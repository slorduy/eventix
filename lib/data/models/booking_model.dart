import 'package:eventix/data/models/event_model.dart';
import 'package:eventix/domain/entities/booking.dart';

class BookingModel {
  final String id;
  final String userId;
  final String eventId;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String currencyCode;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime confirmedAt;
  final EventModel? eventInfo;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.currencyCode,
    required this.status,
    required this.createdAt,
    required this.confirmedAt,
    this.eventInfo,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String);
    final rawEvent = json['event'] ?? json['events'];

    return BookingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      eventId: json['event_id'] as String,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      currencyCode: json['currency_code'] as String,
      status: _bookingStatus(json['status'] as String),
      createdAt: createdAt,
      confirmedAt: DateTime.parse(
        json['confirmed_at'] as String? ?? createdAt.toIso8601String(),
      ),
      eventInfo: rawEvent is Map
          ? EventModel.fromJson(Map<String, dynamic>.from(rawEvent))
          : null,
    );
  }

  Booking toEntity() => Booking(
    id: id,
    userId: userId,
    eventId: eventId,
    eventInfo: eventInfo?.toEntity(),
    quantity: quantity,
    unitPrice: unitPrice,
    totalAmount: totalAmount,
    currencyCode: currencyCode,
    status: status,
    createdAt: createdAt,
    confirmedAt: confirmedAt,
  );

  static BookingStatus _bookingStatus(String value) => switch (value) {
    'confirmed' => BookingStatus.confirmed,
    'cancelled' => BookingStatus.cancelled,
    _ => throw FormatException('Unknown booking status: $value'),
  };
}
