import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/domain/repositories/event_repository.dart';

class EventNotFoundException implements Exception {
  const EventNotFoundException();

  @override
  String toString() => 'Event not found';
}

class GetEventDetailUsecase {
  final EventRepository repository;

  const GetEventDetailUsecase({required this.repository});

  Future<Event> call(String eventId) async {
    final event = await repository.getEventById(eventId);
    if (event == null) throw const EventNotFoundException();
    return event;
  }
}
