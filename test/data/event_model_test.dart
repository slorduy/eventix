import 'package:eventix/data/models/event_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps catalog row fields into an Event entity', () {
    final model = EventModel.fromJson({
      'id': 'event-1',
      'title': 'Concierto',
      'description': 'Música en vivo',
      'image_url': null,
      'category_id': 'category-1',
      'city_id': 'city-1',
      'category': 'Music',
      'city': 'Bogotá',
      'location_name': 'Teatro',
      'address': 'Calle 1',
      'event_date': '2026-10-20T23:00:00.000Z',
      'price': 125000.5,
      'currency_code': 'COP',
      'capacity': 200,
      'available_tickets': 32,
      'is_published': true,
    });

    final event = model.toEntity();

    expect(event.id, 'event-1');
    expect(event.categoryId, 'category-1');
    expect(event.cityId, 'city-1');
    expect(event.category, 'Music');
    expect(event.city, 'Bogotá');
    expect(event.price, 125000.5);
    expect(event.currencyCode, 'COP');
    expect(event.availableTickets, 32);
    expect(event.isPublished, isTrue);
  });
}
