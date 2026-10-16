import 'package:eventix/domain/entities/event.dart';

enum TicketStatus { valid, used, cancelled }

class Ticket {
  final String id;
  final String bookingId;
  final String code;
  final TicketStatus status;
  final DateTime issuedAt;
  final Event? eventInfo;

  const Ticket({
    required this.id,
    required this.bookingId,
    required this.code,
    this.status = TicketStatus.valid,
    required this.issuedAt,
    this.eventInfo,
  });

  /// Backwards-friendly name for the ticket's issue date.
  DateTime get date => issuedAt;
}
