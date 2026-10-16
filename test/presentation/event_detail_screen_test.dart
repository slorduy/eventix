import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/screens/event_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventRepository implements EventRepository {
  final Event? event;

  _FakeEventRepository(this.event);

  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async =>
      event == null ? const [] : [event!].where(filter.matches).toList();

  @override
  Future<Event?> getEventById(String eventId) async =>
      event?.id == eventId ? event : null;
}

void main() {
  testWidgets('shows event details and updates the selected quantity', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            _FakeEventRepository(_event()),
          ),
        ],
        child: const MaterialApp(home: EventDetailScreen(eventId: 'event-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Concierto'), findsOneWidget);
    expect(find.text('Sala norte, Bogotá'), findsOneWidget);
    expect(find.text('32 cupos disponibles'), findsOneWidget);
    expect(find.text('COP 120000'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Agregar una entrada'));
    await tester.pumpAndSettle();

    expect(find.text('2'), findsOneWidget);
    expect(find.text('COP 240000'), findsOneWidget);
  });

  testWidgets('prevents booking when the event is sold out', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            _FakeEventRepository(_event(availableTickets: 0)),
          ),
        ],
        child: const MaterialApp(home: EventDetailScreen(eventId: 'event-1')),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin cupos disponibles'), findsOneWidget);
    expect(find.text('0 cupos disponibles'), findsOneWidget);
  });
}

Event _event({int availableTickets = 32}) => Event(
  id: 'event-1',
  title: 'Concierto',
  description: 'Música en vivo',
  categoryId: 'category-music',
  cityId: 'city-bogota',
  category: 'Music',
  city: 'Bogotá',
  locationName: 'Sala norte',
  eventDate: DateTime.utc(2026, 11, 1, 20),
  price: 120000,
  currencyCode: 'COP',
  capacity: 200,
  availableTickets: availableTickets,
);
