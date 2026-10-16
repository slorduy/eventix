import 'package:eventix/data/datasources/event_datasource.dart';
import 'package:eventix/data/models/event_model.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDatasourceImpl implements EventDatasource {
  final SupabaseClient client;

  const EventDatasourceImpl({required this.client});

  static const _columns =
      'id,title,description,image_url,category,city,location_name,address,'
      'event_date,price,currency_code,capacity,available_tickets,is_published,'
      'category_id,city_id';

  @override
  Future<List<EventModel>> getEvents(EventFilter filter) async {
    if (filter.hasInvalidDateRange) return const [];

    var query = client.from('event_catalog').select(_columns);

    if (filter.categoryId != null) {
      query = query.eq('category_id', filter.categoryId!);
    }

    if (filter.cityId != null) {
      query = query.eq('city_id', filter.cityId!);
    }

    if (filter.dateFrom != null) {
      query = query.gte(
        'event_date',
        _startOfDay(filter.dateFrom!).toUtc().toIso8601String(),
      );
    }

    if (filter.dateTo != null) {
      final endExclusive = _startOfDay(filter.dateTo!)
          .add(const Duration(days: 1));
      query = query.lt('event_date', endExclusive.toUtc().toIso8601String());
    }

    final rows = await query.order('event_date', ascending: true);
    return rows
        .map((row) => EventModel.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }

  @override
  Future<EventModel?> getEventById(String eventId) async {
    final row = await client
        .from('event_catalog')
        .select(_columns)
        .eq('id', eventId)
        .maybeSingle();

    if (row == null) return null;
    return EventModel.fromJson(Map<String, dynamic>.from(row));
  }

  static DateTime _startOfDay(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
