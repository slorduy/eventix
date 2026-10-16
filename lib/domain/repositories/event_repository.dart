import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';

class EventRepositoryException implements Exception {
  final String userMessage;

  const EventRepositoryException(this.userMessage);

  @override
  String toString() => userMessage;
}

abstract class EventRepository {
  Future<List<Event>> getEvents({EventFilter filter = const EventFilter()});

  Future<Event?> getEventById(String eventId);
}
