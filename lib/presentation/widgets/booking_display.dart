import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';

String bookingStatusLabel(BookingStatus status) => switch (status) {
  BookingStatus.confirmed => 'Confirmada',
  BookingStatus.cancelled => 'Cancelada',
};

String ticketStatusLabel(TicketStatus status) => switch (status) {
  TicketStatus.valid => 'Válido',
  TicketStatus.used => 'Usado',
  TicketStatus.cancelled => 'Cancelado',
};

String formatBookingAmount(double amount) => amount == amount.roundToDouble()
    ? amount.toStringAsFixed(0)
    : amount.toStringAsFixed(2);

String formatBookingDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
