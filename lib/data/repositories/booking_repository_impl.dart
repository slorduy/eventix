import 'package:eventix/data/datasources/booking_datasource.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingRepositoryException implements Exception {
  final String userMessage;

  const BookingRepositoryException(this.userMessage);

  @override
  String toString() => userMessage;
}

class InsufficientTicketsException implements Exception {
  const InsufficientTicketsException();

  @override
  String toString() => 'No hay suficientes cupos disponibles.';
}

class BookingRepositoryImpl implements BookingRepository {
  final BookingDatasource datasource;

  const BookingRepositoryImpl({required this.datasource});

  @override
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    try {
      return (await datasource.confirmBooking(
        eventId: eventId,
        quantity: quantity,
        requestId: requestId,
      )).toEntity();
    } on PostgrestException catch (error) {
      if (error.code == 'P0001') throw const InsufficientTicketsException();
      if (error.code == 'P0002') {
        throw const BookingRepositoryException(
          'El evento ya no está disponible.',
        );
      }
      throw const BookingRepositoryException(
        'No fue posible confirmar la reserva. Inténtalo de nuevo.',
      );
    } catch (_) {
      throw const BookingRepositoryException(
        'No fue posible confirmar la reserva. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<List<Booking>> getBookingsByUser(String userId) async {
    try {
      final models = await datasource.getBookingsByUser(userId);
      return models.map((model) => model.toEntity()).toList(growable: false);
    } catch (_) {
      throw const BookingRepositoryException(
        'No fue posible cargar tus reservas. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<Booking?> getBookingById({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final model = await datasource.getBookingById(
        bookingId: bookingId,
        userId: userId,
      );
      return model?.toEntity();
    } catch (_) {
      throw const BookingRepositoryException(
        'No fue posible cargar esta reserva. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<List<Ticket>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  }) async {
    try {
      final models = await datasource.getTicketsByBooking(
        bookingId: bookingId,
        userId: userId,
      );
      return models.map((model) => model.toEntity()).toList(growable: false);
    } catch (_) {
      throw const BookingRepositoryException(
        'No fue posible cargar tus tickets. Inténtalo de nuevo.',
      );
    }
  }
}
