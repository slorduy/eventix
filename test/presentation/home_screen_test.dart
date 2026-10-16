import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/repositories/category_repository.dart';
import 'package:eventix/domain/repositories/city_repository.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventRepository implements EventRepository {
  final List<Event> events;

  _FakeEventRepository(this.events);

  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async => events.where(filter.matches).toList();

  @override
  Future<Event?> getEventById(String eventId) async =>
      events.where((event) => event.id == eventId).firstOrNull;
}

class _FilteredEventFilterNotifier extends EventFilterNotifier {
  @override
  EventFilter build() => const EventFilter(cityId: 'city-atlantis');
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getActiveCategories() async => const [
    Category(id: 'category-music', name: 'Música en vivo'),
    Category(id: 'category-theater', name: 'Teatro'),
  ];
}

class _FakeCityRepository implements CityRepository {
  @override
  Future<List<City>> getActiveCities() async => const [
    City(id: 'city-bogota', name: 'Bogotá', countryCode: 'CO'),
    City(id: 'city-cali', name: 'Cali', countryCode: 'CO'),
  ];
}

void main() {
  testWidgets('shows event cards from the repository', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(
            _FakeEventRepository([_event()]),
          ),
          categoryRepositoryProvider.overrideWithValue(
            _FakeCategoryRepository(),
          ),
          cityRepositoryProvider.overrideWithValue(_FakeCityRepository()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Concierto'), findsOneWidget);
    expect(find.text('Bogotá · Teatro'), findsOneWidget);
    expect(find.text('COP 120000'), findsOneWidget);
    expect(find.byTooltip('Cerrar sesión'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.byType(AppSelect<String?>), findsNWidgets(2));

    await tester.tap(find.byType(AppSelect<String?>).first);
    await tester.pumpAndSettle();
    expect(find.text('Música en vivo'), findsOneWidget);
    await tester.tap(find.text('Música en vivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Aplicar filtros'));
    await tester.pumpAndSettle();
    expect(find.text('Concierto'), findsOneWidget);
  });

  testWidgets('distinguishes an empty catalog from filtered no-results', (
    tester,
  ) async {
    final repository = _FakeEventRepository([]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventRepositoryProvider.overrideWithValue(repository),
          categoryRepositoryProvider.overrideWithValue(
            _FakeCategoryRepository(),
          ),
          cityRepositoryProvider.overrideWithValue(_FakeCityRepository()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aún no hay eventos'), findsOneWidget);

    await tester.pumpWidget(
      ProviderScope(
        key: const ValueKey('filtered-catalog'),
        overrides: [
          eventRepositoryProvider.overrideWithValue(repository),
          categoryRepositoryProvider.overrideWithValue(
            _FakeCategoryRepository(),
          ),
          cityRepositoryProvider.overrideWithValue(_FakeCityRepository()),
          eventFilterProvider.overrideWith(_FilteredEventFilterNotifier.new),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -320));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Limpiar filtros'));
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay eventos'), findsOneWidget);
  });
}

Event _event() => Event(
  id: 'event-1',
  title: 'Concierto',
  description: 'Música en vivo',
  categoryId: 'category-music',
  cityId: 'city-bogota',
  category: 'Music',
  city: 'Bogotá',
  locationName: 'Teatro',
  eventDate: DateTime.utc(2026, 11, 1, 20),
  price: 120000,
  currencyCode: 'COP',
  capacity: 200,
  availableTickets: 32,
);
