import 'package:eventix/data/datasources/event_datasource_impl.dart';
import 'package:eventix/data/datasources/category_datasource_impl.dart';
import 'package:eventix/data/datasources/city_datasource_impl.dart';
import 'package:eventix/data/repositories/category_repository_impl.dart';
import 'package:eventix/data/repositories/city_repository_impl.dart';
import 'package:eventix/data/repositories/event_repository_impl.dart';
import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/repositories/category_repository.dart';
import 'package:eventix/domain/repositories/city_repository.dart';
import 'package:eventix/domain/repositories/event_repository.dart';
import 'package:eventix/domain/usecases/get_categories_usecase.dart';
import 'package:eventix/domain/usecases/get_cities_usecase.dart';
import 'package:eventix/domain/usecases/get_event_detail_usecase.dart';
import 'package:eventix/domain/usecases/get_events_usecase.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventDatasourceProvider = Provider((ref) {
  return EventDatasourceImpl(client: ref.watch(supabaseClientProvider));
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(datasource: ref.watch(eventDatasourceProvider));
});

final getEventsUsecaseProvider = Provider((ref) {
  return GetEventsUsecase(repository: ref.watch(eventRepositoryProvider));
});

final categoryDatasourceProvider = Provider((ref) {
  return CategoryDatasourceImpl(client: ref.watch(supabaseClientProvider));
});

final cityDatasourceProvider = Provider((ref) {
  return CityDatasourceImpl(client: ref.watch(supabaseClientProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    datasource: ref.watch(categoryDatasourceProvider),
  );
});

final cityRepositoryProvider = Provider<CityRepository>((ref) {
  return CityRepositoryImpl(datasource: ref.watch(cityDatasourceProvider));
});

final getCategoriesUsecaseProvider = Provider((ref) {
  return GetCategoriesUsecase(
    repository: ref.watch(categoryRepositoryProvider),
  );
});

final getCitiesUsecaseProvider = Provider((ref) {
  return GetCitiesUsecase(repository: ref.watch(cityRepositoryProvider));
});

final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(getCategoriesUsecaseProvider)();
});

final citiesProvider = FutureProvider.autoDispose<List<City>>((ref) {
  return ref.watch(getCitiesUsecaseProvider)();
});

final getEventDetailUsecaseProvider = Provider((ref) {
  return GetEventDetailUsecase(repository: ref.watch(eventRepositoryProvider));
});

class EventFilterNotifier extends Notifier<EventFilter> {
  @override
  EventFilter build() => const EventFilter();

  void setFilter(EventFilter filter) => state = filter;

  void clear() => state = const EventFilter();
}

final eventFilterProvider = NotifierProvider<EventFilterNotifier, EventFilter>(
  EventFilterNotifier.new,
);

final eventsProvider = FutureProvider.autoDispose<List<Event>>((ref) {
  final filter = ref.watch(eventFilterProvider);
  return ref.watch(getEventsUsecaseProvider)(filter: filter);
});

final eventDetailProvider = FutureProvider.autoDispose.family<Event, String>((
  ref,
  eventId,
) {
  return ref.watch(getEventDetailUsecaseProvider)(eventId);
});

class EventQuantityNotifier extends Notifier<int> {
  final String eventId;

  EventQuantityNotifier(this.eventId);

  @override
  int build() => 1;

  void increase(int availableTickets) {
    if (availableTickets > 0 && state < availableTickets) state++;
  }

  void decrease(int availableTickets) {
    if (availableTickets <= 0) return;
    state = state.clamp(1, availableTickets).toInt();
    if (state > 1) state--;
  }
}

final eventQuantityProvider = NotifierProvider.autoDispose
    .family<EventQuantityNotifier, int, String>(EventQuantityNotifier.new);
