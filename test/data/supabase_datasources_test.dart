import 'dart:convert';

import 'package:eventix/data/datasources/auth_user_datasource_impl.dart';
import 'package:eventix/data/datasources/booking_datasource_impl.dart';
import 'package:eventix/data/datasources/category_datasource_impl.dart';
import 'package:eventix/data/datasources/city_datasource_impl.dart';
import 'package:eventix/data/datasources/event_datasource_impl.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('EventDatasourceImpl', () {
    test('applies catalog ID/date filters and maps event rows', () async {
      final requests = <http.Request>[];
      final client = _supabaseClient((request) async {
        requests.add(request);
        return _jsonResponse([_eventRow()]);
      });
      addTearDown(client.dispose);

      final events = await EventDatasourceImpl(client: client).getEvents(
        EventFilter(
          categoryId: 'category-1',
          cityId: 'city-1',
          dateFrom: DateTime(2026, 10, 20),
          dateTo: DateTime(2026, 10, 21),
        ),
      );

      expect(events.single.id, 'event-1');
      expect(events.single.categoryId, 'category-1');
      expect(events.single.city, 'Bogotá');
      expect(requests.single.url.path, endsWith('/event_catalog'));
      expect(
        requests.single.url.queryParameters['category_id'],
        'eq.category-1',
      );
      expect(requests.single.url.queryParameters['city_id'], 'eq.city-1');
      expect(
        requests.single.url.queryParametersAll['event_date'],
        containsAll([startsWith('gte.'), startsWith('lt.')]),
      );
    });

    test('rejects an invalid range without a request', () async {
      var requestCount = 0;
      final client = _supabaseClient((request) async {
        requestCount++;
        return _jsonResponse([]);
      });
      addTearDown(client.dispose);

      final rows = await EventDatasourceImpl(client: client).getEvents(
        EventFilter(
          dateFrom: DateTime(2026, 10, 22),
          dateTo: DateTime(2026, 10, 20),
        ),
      );

      expect(rows, isEmpty);
      expect(requestCount, 0);
    });

    test('loads an event by ID and maps a missing row to null', () async {
      final responses = <dynamic>[_eventRow(), <dynamic>[]];
      final requestedIds = <String?>[];
      final client = _supabaseClient((request) async {
        requestedIds.add(request.url.queryParameters['id']);
        return _jsonResponse(responses.removeAt(0));
      });
      addTearDown(client.dispose);
      final datasource = EventDatasourceImpl(client: client);

      expect((await datasource.getEventById('event-1'))?.title, 'Concierto');
      expect(await datasource.getEventById('missing'), isNull);
      expect(requestedIds, ['eq.event-1', 'eq.missing']);
    });
  });

  group('BookingDatasourceImpl', () {
    test('calls confirmation RPC and maps its booking result', () async {
      final client = _supabaseClient((request) async {
        expect(request.url.path, endsWith('/rpc/confirm_event_booking'));
        expect(jsonDecode(request.body), {
          'p_event_id': 'event-1',
          'p_quantity': 2,
          'p_request_id': 'request-1',
        });
        return _jsonResponse({'booking': _bookingRow()});
      });
      addTearDown(client.dispose);

      final booking = await BookingDatasourceImpl(
        client: client,
      ).confirmBooking(eventId: 'event-1', quantity: 2, requestId: 'request-1');

      expect(booking.id, 'booking-1');
      expect(booking.totalAmount, 200);
    });

    test(
      'queries user bookings and applies both detail ownership filters',
      () async {
        final responseRows = <dynamic>[
          [_bookingRow()],
          _bookingRow(),
          <dynamic>[],
        ];
        final requests = <http.Request>[];
        final client = _supabaseClient((request) async {
          requests.add(request);
          return _jsonResponse(responseRows.removeAt(0));
        });
        addTearDown(client.dispose);
        final datasource = BookingDatasourceImpl(client: client);

        expect(
          (await datasource.getBookingsByUser('user-1')).single.id,
          'booking-1',
        );
        expect(requests[0].url.queryParameters['user_id'], 'eq.user-1');
        expect(
          (await datasource.getBookingById(
            bookingId: 'booking-1',
            userId: 'user-1',
          ))?.id,
          'booking-1',
        );
        expect(requests[1].url.queryParameters['id'], 'eq.booking-1');
        expect(requests[1].url.queryParameters['user_id'], 'eq.user-1');
        expect(
          await datasource.getBookingById(
            bookingId: 'booking-2',
            userId: 'user-1',
          ),
          isNull,
        );
      },
    );

    test('loads tickets scoped by booking and user', () async {
      final client = _supabaseClient((request) async {
        expect(request.url.path, endsWith('/tickets'));
        expect(request.url.queryParameters['booking_id'], 'eq.booking-1');
        expect(request.url.queryParameters['user_id'], 'eq.user-1');
        return _jsonResponse([
          {
            'id': 'ticket-1',
            'booking_id': 'booking-1',
            'ticket_code': 'CODE-1',
            'status': 'valid',
            'issued_at': '2026-10-20T10:00:00Z',
          },
        ]);
      });
      addTearDown(client.dispose);

      final tickets = await BookingDatasourceImpl(client: client)
          .getTicketsByBooking(bookingId: 'booking-1', userId: 'user-1');

      expect(tickets.single.code, 'CODE-1');
    });
  });

  group('Catalog datasources', () {
    test('loads active categories', () async {
      final client = _supabaseClient((request) async {
        expect(request.url.path, endsWith('/categories'));
        expect(request.url.queryParameters['is_active'], 'eq.true');
        return _jsonResponse([
          {'id': 'category-1', 'name': 'Teatro', 'is_active': true},
        ]);
      });
      addTearDown(client.dispose);

      final result = await CategoryDatasourceImpl(client: client)
          .getActiveCategories();

      expect(result.single.name, 'Teatro');
    });

    test('loads active cities with country codes', () async {
      final client = _supabaseClient((request) async {
        expect(request.url.path, endsWith('/cities'));
        expect(request.url.queryParameters['is_active'], 'eq.true');
        return _jsonResponse([
          {
            'id': 'city-1',
            'name': 'Cali',
            'country_code': 'CO',
            'is_active': true,
          },
        ]);
      });
      addTearDown(client.dispose);

      final result = await CityDatasourceImpl(client: client).getActiveCities();

      expect(result.single.name, 'Cali');
      expect(result.single.countryCode, 'CO');
    });
  });

  group('AuthUserDatasourceImpl', () {
    test('returns null when signup requires email confirmation', () async {
      final client = _supabaseClient((request) async {
        expect(request.url.path, endsWith('/signup'));
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['email'], 'ana@example.com');
        expect(body['password'], 'password123');
        expect(body['data'], {'first_name': 'Ana', 'last_name': 'López'});
        return _jsonResponse({
          'id': 'user-1',
          'aud': 'authenticated',
          'role': 'authenticated',
          'email': 'ana@example.com',
          'created_at': '2026-10-20T10:00:00Z',
          'user_metadata': {'first_name': 'Ana', 'last_name': 'López'},
        });
      });
      addTearDown(client.dispose);

      final user = await AuthUserDatasourceImpl(client: client)
          .signUp('ana@example.com', 'Ana', 'López', 'password123');

      expect(user, isNull);
    });

    test(
      'does not load another user profile and signs out without a session',
      () async {
        final client = _supabaseClient((request) async {
          fail('No request should be sent without the requested auth session');
        });
        addTearDown(client.dispose);
        final datasource = AuthUserDatasourceImpl(client: client);

        expect(await datasource.getCurrentUserInfo('different-user'), isNull);
        await datasource.logout();
      },
    );
  });
}

SupabaseClient _supabaseClient(
  Future<http.Response> Function(http.Request request) handler,
) => SupabaseClient(
  'https://eventix-test.supabase.co',
  'test-anon-key',
  authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
  httpClient: MockClient((request) async {
    final response = await handler(request);
    return http.Response(
      response.body,
      response.statusCode,
      request: request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }),
);

http.Response _jsonResponse(dynamic body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);

Map<String, dynamic> _eventRow() => {
  'id': 'event-1',
  'title': 'Concierto',
  'description': 'Música en vivo',
  'image_url': null,
  'category_id': 'category-1',
  'city_id': 'city-1',
  'category': 'Música en vivo',
  'city': 'Bogotá',
  'location_name': 'Teatro',
  'address': null,
  'event_date': '2026-11-01T20:00:00Z',
  'price': 100,
  'currency_code': 'COP',
  'capacity': 50,
  'available_tickets': 10,
  'is_published': true,
};

Map<String, dynamic> _bookingRow() => {
  'id': 'booking-1',
  'user_id': 'user-1',
  'event_id': 'event-1',
  'quantity': 2,
  'unit_price': 100,
  'total_amount': 200,
  'currency_code': 'COP',
  'status': 'confirmed',
  'created_at': '2026-10-20T10:00:00Z',
  'confirmed_at': '2026-10-20T10:00:00Z',
};
