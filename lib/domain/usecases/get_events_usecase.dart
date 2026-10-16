import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/domain/repositories/event_repository.dart';

class GetEventsUsecase {
  final EventRepository repository;

  GetEventsUsecase({required this.repository});

  Future<List<Event>> call({EventFilter filter = const EventFilter()}) {
    return repository.getEvents(filter: filter);
  }
}
