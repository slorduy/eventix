import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

Event _event({
  String category = 'Music',
  String city = 'Bogotá',
  String categoryId = 'category-music',
  String cityId = 'city-bogota',
  DateTime? eventDate,
}) {
  return Event(
    id: 'event-1',
    title: 'Concierto',
    description: 'Evento de prueba',
    categoryId: categoryId,
    cityId: cityId,
    category: category,
    city: city,
    locationName: 'Teatro',
    eventDate: eventDate ?? DateTime(2026, 10, 20, 18),
    price: 120000,
    currencyCode: 'COP',
    capacity: 100,
    availableTickets: 42,
  );
}

void main() {
  group('EventFilter', () {
    test('empty filter matches any event', () {
      const filter = EventFilter();

      expect(filter.isEmpty, isTrue);
      expect(filter.matches(_event()), isTrue);
    });

    test('combines category, city, and inclusive calendar date range', () {
      final filter = EventFilter(
        categoryId: 'category-music',
        cityId: 'city-bogota',
        dateFrom: DateTime(2026, 10, 20),
        dateTo: DateTime(2026, 10, 20),
      );

      expect(filter.matches(_event()), isTrue);
      expect(filter.matches(_event(cityId: 'city-medellin')), isFalse);
      expect(filter.matches(_event(categoryId: 'category-theater')), isFalse);
      expect(
        filter.matches(_event(eventDate: DateTime(2026, 10, 21, 0, 1))),
        isFalse,
      );
    });

    test('rejects an invalid date range', () {
      final filter = EventFilter(
        dateFrom: DateTime(2026, 10, 21),
        dateTo: DateTime(2026, 10, 20),
      );

      expect(filter.hasInvalidDateRange, isTrue);
      expect(filter.matches(_event()), isFalse);
    });

    test('null catalog IDs mean no category or city filter', () {
      const filter = EventFilter(categoryId: null, cityId: null);

      expect(filter.isEmpty, isTrue);
      expect(filter.matches(_event()), isTrue);
    });
  });
}
