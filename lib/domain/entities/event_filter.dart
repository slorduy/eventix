import 'package:eventix/domain/entities/event.dart';

/// Date boundaries are interpreted as calendar dates in the user's local time
/// zone and are inclusive. Category and city selections are catalog UUIDs;
/// a null ID means that dimension is not filtered.
class EventFilter {
  final String? categoryId;
  final String? cityId;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const EventFilter({this.categoryId, this.cityId, this.dateFrom, this.dateTo});

  bool get isEmpty =>
      categoryId == null &&
      cityId == null &&
      dateFrom == null &&
      dateTo == null;

  bool get hasInvalidDateRange =>
      dateFrom != null &&
      dateTo != null &&
      _calendarDate(dateFrom!).isAfter(_calendarDate(dateTo!));

  bool matches(Event event) {
    if (hasInvalidDateRange) return false;

    if (categoryId != null && event.categoryId != categoryId) {
      return false;
    }

    if (cityId != null && event.cityId != cityId) {
      return false;
    }

    final eventDate = _calendarDate(event.eventDate);
    if (dateFrom != null && eventDate.isBefore(_calendarDate(dateFrom!))) {
      return false;
    }
    if (dateTo != null && eventDate.isAfter(_calendarDate(dateTo!))) {
      return false;
    }

    return true;
  }

  static DateTime _calendarDate(DateTime value) {
    final local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
