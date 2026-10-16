import 'package:eventix/data/models/event_model.dart';
import 'package:eventix/domain/entities/event_filter.dart';

abstract class EventDatasource {
  Future<List<EventModel>> getEvents(EventFilter filter);

  Future<EventModel?> getEventById(String eventId);
}
