import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/repositories/category_repository.dart';
import 'package:eventix/domain/repositories/city_repository.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEventRepository implements EventRepository {
  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async => const [];

  @override
  Future<Event?> getEventById(String eventId) async => null;
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getActiveCategories() async => const [
    Category(id: 'category-1', name: 'Teatro'),
  ];
}

class _FakeCityRepository implements CityRepository {
  @override
  Future<List<City>> getActiveCities() async => const [
    City(id: 'city-1', name: 'Bogotá', countryCode: 'CO'),
  ];
}

void main() {
  test('event repository provider can be overridden for tests', () {
    final repository = _FakeEventRepository();
    final container = ProviderContainer(
      overrides: [eventRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    expect(container.read(eventRepositoryProvider), same(repository));
  });

  test('event filters can be changed and cleared', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container
        .read(eventFilterProvider.notifier)
        .setFilter(
          const EventFilter(
            categoryId: 'category-music',
            cityId: 'city-bogota',
          ),
        );
    expect(container.read(eventFilterProvider).categoryId, 'category-music');
    expect(container.read(eventFilterProvider).cityId, 'city-bogota');

    container.read(eventFilterProvider.notifier).clear();
    expect(container.read(eventFilterProvider).isEmpty, isTrue);
  });

  test('lookup providers return active select options', () async {
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(_FakeCategoryRepository()),
        cityRepositoryProvider.overrideWithValue(_FakeCityRepository()),
      ],
    );
    addTearDown(container.dispose);

    final categories = await container.read(categoriesProvider.future);
    final cities = await container.read(citiesProvider.future);

    expect(categories.single.id, 'category-1');
    expect(categories.single.name, 'Teatro');
    expect(cities.single.id, 'city-1');
    expect(cities.single.countryCode, 'CO');
  });
}
