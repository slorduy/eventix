import 'package:eventix/data/datasources/booking_datasource.dart';
import 'package:eventix/data/models/booking_model.dart';
import 'package:eventix/data/models/ticket_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDatasourceImpl implements BookingDatasource {
  final SupabaseClient client;

  const BookingDatasourceImpl({required this.client});

  static const _bookingColumns =
      'id,user_id,event_id,quantity,unit_price,total_amount,currency_code,'
      'status,created_at,confirmed_at,'
      'event:events(id,title,description,image_url,category_id,city_id,'
      'category_ref:categories!events_category_id_fkey(id,name),'
      'city_ref:cities!events_city_id_fkey(id,name),location_name,address,'
      'event_date,price,currency_code,capacity,is_published)';

  static const _ticketColumns =
      'id,booking_id,ticket_code,status,issued_at,purchase_date,created_at';

  @override
  Future<BookingModel> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    final response = await client.rpc(
      'confirm_event_booking',
      params: {
        'p_event_id': eventId,
        'p_quantity': quantity,
        'p_request_id': requestId,
      },
    );

    final result = Map<String, dynamic>.from(response as Map);
    final booking = Map<String, dynamic>.from(result['booking'] as Map);
    return BookingModel.fromJson(booking);
  }

  @override
  Future<List<BookingModel>> getBookingsByUser(String userId) async {
    final rows = await client
        .from('bookings')
        .select(_bookingColumns)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows
        .map((row) => BookingModel.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<BookingModel?> getBookingById({
    required String bookingId,
    required String userId,
  }) async {
    final row = await client
        .from('bookings')
        .select(_bookingColumns)
        .eq('id', bookingId)
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return null;
    return BookingModel.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<List<TicketModel>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  }) async {
    final rows = await client
        .from('tickets')
        .select(_ticketColumns)
        .eq('booking_id', bookingId)
        .eq('user_id', userId)
        .order('issued_at', ascending: true);

    return rows
        .map((row) => TicketModel.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}
