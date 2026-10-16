import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/entities/ticket.dart';
import 'package:eventix/domain/entities/user.dart';
import 'package:eventix/domain/repositories/auth_user_repository.dart';
import 'package:eventix/domain/repositories/booking_repository.dart';
import 'package:eventix/domain/repositories/category_repository.dart';
import 'package:eventix/domain/repositories/city_repository.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/providers/booking_providers.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/screens/booking_confirmation_screen.dart';
import 'package:eventix/presentation/screens/booking_detail_screen.dart';
import 'package:eventix/presentation/screens/event_detail_screen.dart';
import 'package:eventix/presentation/screens/home_screen.dart';
import 'package:eventix/presentation/screens/login_screen.dart';
import 'package:eventix/presentation/screens/my_bookings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

class _FakeAuthRepository implements AuthUserRepository {
  @override
  Future<User?> signIn(String email, String password) async => const User(
    id: 'user-1',
    name: 'Ana',
    lastName: 'López',
    email: 'ana@example.com',
  );

  @override
  Future<User?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  ) async => null;

  @override
  Future<User?> getCurrentUserInfo(String id) async => null;

  @override
  Future<void> logout() async {}
}

class _FakeEventRepository implements EventRepository {
  var availableTickets = 10;
  var listCalls = 0;
  EventFilter lastFilter = const EventFilter();

  Event get event => _event(availableTickets: availableTickets);

  @override
  Future<List<Event>> getEvents({
    EventFilter filter = const EventFilter(),
  }) async {
    listCalls++;
    lastFilter = filter;
    return [event].where(filter.matches).toList();
  }

  @override
  Future<Event?> getEventById(String eventId) async =>
      eventId == event.id ? event : null;
}

class _FakeCategoryRepository implements CategoryRepository {
  @override
  Future<List<Category>> getActiveCategories() async => const [
    Category(id: 'category-music', name: 'Música en vivo'),
  ];
}

class _FakeCityRepository implements CityRepository {
  @override
  Future<List<City>> getActiveCities() async => const [
    City(id: 'city-bogota', name: 'Bogotá', countryCode: 'CO'),
  ];
}

class _FakeBookingRepository implements BookingRepository {
  final _FakeEventRepository eventRepository;
  Booking? _booking;
  var confirmCalls = 0;

  _FakeBookingRepository(this.eventRepository);

  @override
  Future<Booking> confirmBooking({
    required String eventId,
    required int quantity,
    required String requestId,
  }) async {
    confirmCalls++;
    eventRepository.availableTickets -= quantity;
    final now = DateTime.utc(2026, 10, 16);
    return _booking = Booking(
      id: 'booking-1',
      userId: 'user-1',
      eventId: eventId,
      eventInfo: _event(),
      quantity: quantity,
      unitPrice: 100.0,
      totalAmount: 100.0 * quantity,
      currencyCode: 'COP',
      createdAt: now,
      confirmedAt: now,
    );
  }

  @override
  Future<List<Booking>> getBookingsByUser(String userId) async =>
      userId == 'user-1' && _booking != null ? [_booking!] : const [];

  @override
  Future<Booking?> getBookingById({
    required String bookingId,
    required String userId,
  }) async =>
      _booking?.id == bookingId && _booking?.userId == userId ? _booking : null;

  @override
  Future<List<Ticket>> getTicketsByBooking({
    required String bookingId,
    required String userId,
  }) async => _booking?.id == bookingId && _booking?.userId == userId
      ? [
          Ticket(
            id: 'ticket-1',
            bookingId: bookingId,
            code: 'EVENTIX-TICKET-1',
            issuedAt: DateTime.utc(2026, 10, 16),
          ),
        ]
      : const [];
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login, load an event, reserve tickets, and view the booking', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final eventRepository = _FakeEventRepository();
    final bookingRepository = _FakeBookingRepository(eventRepository);
    final router = GoRouter(
      initialLocation: '/sign-in',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) =>
              LoginScreen(redirectTo: state.uri.queryParameters['from']),
        ),
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/events/:eventId',
          builder: (context, state) =>
              EventDetailScreen(eventId: state.pathParameters['eventId']!),
        ),
        GoRoute(
          path: '/events/:eventId/confirmation',
          builder: (context, state) => BookingConfirmationScreen(
            eventId: state.pathParameters['eventId']!,
            quantity: int.parse(state.uri.queryParameters['quantity']!),
          ),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => const MyBookingsScreen(),
        ),
        GoRoute(
          path: '/bookings/:bookingId',
          builder: (context, state) => BookingDetailScreen(
            bookingId: state.pathParameters['bookingId']!,
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserRepositoryProvider.overrideWithValue(authRepository),
          currentAuthUserIdProvider.overrideWithValue('user-1'),
          eventRepositoryProvider.overrideWithValue(eventRepository),
          categoryRepositoryProvider.overrideWithValue(
            _FakeCategoryRepository(),
          ),
          cityRepositoryProvider.overrideWithValue(_FakeCityRepository()),
          bookingRepositoryProvider.overrideWithValue(bookingRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'ana@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.ensureVisible(find.text('Iniciar Sesion'));
    await tester.tap(find.text('Iniciar Sesion'));
    await tester.pumpAndSettle();

    expect(find.text('Eventos'), findsOneWidget);
    expect(find.text('10 cupos disponibles'), findsOneWidget);
    await tester.tap(find.byType(AppSelect<String?>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Música en vivo').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();
    expect(eventRepository.lastFilter.categoryId, 'category-music');
    final initialEventLoads = eventRepository.listCalls;
    await tester.ensureVisible(find.text('Concierto'));
    expect(find.text('Concierto'), findsOneWidget);
    await tester.tap(find.text('Concierto'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle del evento'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Agregar una entrada'));
    await tester.tap(find.byTooltip('Agregar una entrada'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Continuar'));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('COP 200'), findsOneWidget);
    final confirmButton = find.widgetWithText(
      OutlinedButton,
      'Confirmar reserva',
    );
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await tester.pumpAndSettle();

    expect(bookingRepository.confirmCalls, 1);
    expect(find.text('Reserva confirmada'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Reserva confirmada'), findsOneWidget);
    await tester.ensureVisible(find.text('Volver al inicio'));
    expect(
      tester.getTopLeft(find.text('Ver mis reservas')).dy,
      lessThan(tester.getTopLeft(find.text('Volver al inicio')).dy),
    );

    await tester.ensureVisible(find.text('Ver mis reservas'));
    await tester.tap(find.text('Ver mis reservas'));
    await tester.pumpAndSettle();

    expect(find.text('Mis reservas'), findsOneWidget);
    expect(find.text('Concierto'), findsOneWidget);
    expect(find.text('2 entradas'), findsOneWidget);
    expect(find.text('COP 200'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Reserva confirmada'), findsOneWidget);
    await tester.ensureVisible(find.text('Volver al inicio'));
    await tester.tap(find.text('Volver al inicio'));
    await tester.pumpAndSettle();

    expect(find.text('Eventos'), findsOneWidget);
    expect(eventRepository.listCalls, greaterThan(initialEventLoads));
    expect(find.text('8 cupos disponibles'), findsOneWidget);
    expect(
      tester
          .widget<AppSelect<String?>>(find.byType(AppSelect<String?>).first)
          .value,
      'category-music',
    );
    expect(eventRepository.lastFilter.categoryId, 'category-music');
  });
}

Event _event({int availableTickets = 10}) => Event(
  id: 'event-1',
  title: 'Concierto',
  description: 'Música en vivo',
  categoryId: 'category-music',
  cityId: 'city-bogota',
  category: 'Música en vivo',
  city: 'Bogotá',
  locationName: 'Teatro',
  eventDate: DateTime.utc(2026, 11, 1, 20),
  price: 100,
  currencyCode: 'COP',
  capacity: 50,
  availableTickets: availableTickets,
);
