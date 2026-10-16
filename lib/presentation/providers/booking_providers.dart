import 'package:eventix/data/datasources/booking_datasource_impl.dart';
import 'package:eventix/data/repositories/booking_repository_impl.dart';
import 'package:eventix/core/utils/uuid_generator.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';
import 'package:eventix/domain/usecases/confirm_booking_usecase.dart';
import 'package:eventix/domain/usecases/get_booking_detail_usecase.dart';
import 'package:eventix/domain/usecases/get_booking_tickets_usecase.dart';
import 'package:eventix/domain/usecases/get_user_booking_usecase.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingDatasourceProvider = Provider((ref) {
  return BookingDatasourceImpl(client: ref.watch(supabaseClientProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepositoryImpl(
    datasource: ref.watch(bookingDatasourceProvider),
  );
});

final confirmBookingUsecaseProvider = Provider((ref) {
  return ConfirmBookingUsecase(
    repository: ref.watch(bookingRepositoryProvider),
  );
});

final getUserBookingUsecaseProvider = Provider((ref) {
  return GetUserBookingUsecase(
    repository: ref.watch(bookingRepositoryProvider),
  );
});

final getBookingDetailUsecaseProvider = Provider((ref) {
  return GetBookingDetailUsecase(
    repository: ref.watch(bookingRepositoryProvider),
  );
});

final getBookingTicketsUsecaseProvider = Provider((ref) {
  return GetBookingTicketsUsecase(
    repository: ref.watch(bookingRepositoryProvider),
  );
});

final userBookingsProvider = FutureProvider.autoDispose
    .family<List<Booking>, String>((ref, userId) {
      return ref.watch(getUserBookingUsecaseProvider)(userId);
    });

final bookingDetailProvider = FutureProvider.autoDispose
    .family<Booking?, ({String bookingId, String userId})>((ref, params) {
      return ref.watch(getBookingDetailUsecaseProvider)(
        bookingId: params.bookingId,
        userId: params.userId,
      );
    });

final bookingTicketsProvider = FutureProvider.autoDispose
    .family<List<Ticket>, ({String bookingId, String userId})>((ref, params) {
      return ref.watch(getBookingTicketsUsecaseProvider)(
        bookingId: params.bookingId,
        userId: params.userId,
      );
    });

typedef BookingConfirmationIntent = ({String eventId, int quantity});

class BookingConfirmationNotifier extends Notifier<AsyncValue<Booking?>> {
  final BookingConfirmationIntent intent;
  String? _requestId;

  BookingConfirmationNotifier(this.intent);

  @override
  AsyncValue<Booking?> build() => const AsyncData(null);

  Future<Booking> confirm() async {
    if (state.isLoading) {
      throw StateError('A booking confirmation is already in progress.');
    }

    _requestId ??= generateUuidV4();

    state = const AsyncLoading();
    try {
      final booking = await ref.read(confirmBookingUsecaseProvider)(
        eventId: intent.eventId,
        quantity: intent.quantity,
        requestId: _requestId!,
      );
      state = AsyncData(booking);
      _requestId = null;
      return booking;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final bookingConfirmationProvider = NotifierProvider.autoDispose
    .family<
      BookingConfirmationNotifier,
      AsyncValue<Booking?>,
      BookingConfirmationIntent
    >((intent) => BookingConfirmationNotifier(intent));

String? bookingConfirmationErrorMessage(Object? error) {
  if (error == null) return null;
  if (error is InsufficientTicketsException ||
      error is BookingRepositoryException) {
    return error.toString();
  }
  return 'No fue posible confirmar la reserva. Inténtalo de nuevo.';
}
