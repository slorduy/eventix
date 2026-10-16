import 'package:eventix/domain/entities/ticket.dart';

class TicketModel {
  final String id;
  final String bookingId;
  final String code;
  final TicketStatus status;
  final DateTime issuedAt;

  const TicketModel({
    required this.id,
    required this.bookingId,
    required this.code,
    required this.status,
    required this.issuedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final issueDate =
        json['issued_at'] ?? json['purchase_date'] ?? json['created_at'];
    if (issueDate is! String) {
      throw const FormatException('Ticket issue date is missing');
    }

    return TicketModel(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      code: (json['ticket_code'] ?? json['code']) as String,
      status: _ticketStatus(json['status'] as String),
      issuedAt: DateTime.parse(issueDate),
    );
  }

  Ticket toEntity() => Ticket(
    id: id,
    bookingId: bookingId,
    code: code,
    status: status,
    issuedAt: issuedAt,
  );

  static TicketStatus _ticketStatus(String value) => switch (value) {
    'valid' => TicketStatus.valid,
    'used' => TicketStatus.used,
    'cancelled' => TicketStatus.cancelled,
    _ => throw FormatException('Unknown ticket status: $value'),
  };
}
