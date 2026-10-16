import 'package:eventix/data/datasources/event_datasource.dart';
import 'package:eventix/data/models/event_model.dart';
import 'package:eventix/data/repositories/event_repository_impl.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventDatasource implements EventDatasource {
  EventFilter? requestedFilter;
  String? requestedEventId;
  List<EventModel> events = const [];
  EventModel? event;
  Object? error;

  @override
  Future<List<EventModel>> getEvents(EventFilter filter) async {
    requestedFilter = filter;
    if (error != null) throw error!;
    return events;
  }

  @override
  Future<EventModel?> getEventById(String eventId) async {
    requestedEventId = eventId;
    if (error != null) throw error!;
    return event;
  }
}

void main() {
  test('passes filters to the datasource and maps returned models', () async {
    final datasource = _FakeEventDatasource()..events = [_sampleModel()];
    final filter = EventFilter(cityId: 'city-bogota');

    final events = await EventRepositoryImpl(datasource: datasource)
        .getEvents(filter: filter);

    expect(datasource.requestedFilter, same(filter));
    expect(events.single.id, 'event-1');
    expect(events.single.city, 'Bogotá');
  });

  test('maps not-found event to null', () async {
    final datasource = _FakeEventDatasource();

    final event = await EventRepositoryImpl(datasource: datasource)
        .getEventById('missing');

    expect(event, isNull);
    expect(datasource.requestedEventId, 'missing');
  });

  test('maps datasource errors to a safe user-facing exception', () async {
    final datasource = _FakeEventDatasource()
      ..error = Exception('internal detail');

    await expectLater(
      EventRepositoryImpl(datasource: datasource).getEvents(),
      throwsA(
        isA<EventRepositoryException>().having(
          (error) => error.userMessage,
          'userMessage',
          contains('Inténtalo de nuevo'),
        ),
      ),
    );
  });
}

EventModel _sampleModel() => EventModel(
  id: 'event-1',
  title: 'Concierto',
  description: 'Evento de prueba',
  categoryId: 'category-music',
  cityId: 'city-bogota',
  category: 'Music',
  city: 'Bogotá',
  locationName: 'Teatro',
  eventDate: DateTime.utc(2026, 10, 20),
  price: 100,
  currencyCode: 'COP',
  capacity: 100,
  availableTickets: 20,
  isPublished: true,
);
