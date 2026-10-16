import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:eventix/domain/usecases/get_event_detail_usecase.dart';
import 'package:eventix/domain/usecases/get_events_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventRepository implements EventRepository {
  EventFilter? requestedFilter;
  String? requestedEventId;
  List<Event> events = const [];
  Event? event;

  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async {
    requestedFilter = filter;
    return events;
  }

  @override
  Future<Event?> getEventById(String eventId) async {
    requestedEventId = eventId;
    return event;
  }
}

void main() {
  test('GetEventsUsecase forwards the selected filters', () async {
    final repository = _FakeEventRepository();
    const filter = EventFilter(
      categoryId: 'category-music',
      cityId: 'city-bogota',
    );

    await GetEventsUsecase(repository: repository)(filter: filter);

    expect(repository.requestedFilter, same(filter));
  });

  test('GetEventDetailUsecase returns the event from the repository', () async {
    final repository = _FakeEventRepository()..event = _sampleEvent();

    final result = await GetEventDetailUsecase(repository: repository)(
      'event-1',
    );

    expect(result, same(repository.event));
    expect(repository.requestedEventId, 'event-1');
  });

  test('GetEventDetailUsecase reports a missing event', () async {
    final repository = _FakeEventRepository();

    expect(
      () => GetEventDetailUsecase(repository: repository)('missing'),
      throwsA(isA<EventNotFoundException>()),
    );
  });
}

Event _sampleEvent() => Event(
  id: 'event-1',
  title: 'Concierto',
  description: 'Evento de prueba',
  categoryId: 'category-music',
  cityId: 'city-bogota',
  category: 'Music',
  city: 'Bogotá',
  locationName: 'Teatro',
  eventDate: DateTime(2026, 10, 20),
  price: 100,
  currencyCode: 'COP',
  capacity: 100,
  availableTickets: 10,
);
