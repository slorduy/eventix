import 'package:eventix/data/datasources/event_datasource.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventDatasource datasource;

  const EventRepositoryImpl({required this.datasource});

  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async {
    try {
      final models = await datasource.getEvents(filter);
      return models.map((model) => model.toEntity()).toList(growable: false);
    } catch (_) {
      throw const EventRepositoryException(
        'No fue posible cargar los eventos. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<Event?> getEventById(String eventId) async {
    try {
      final model = await datasource.getEventById(eventId);
      return model?.toEntity();
    } catch (_) {
      throw const EventRepositoryException(
        'No fue posible cargar el evento. Inténtalo de nuevo.',
      );
    }
  }
}
