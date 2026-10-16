import 'package:eventix/domain/entities/event.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String categoryId;
  final String cityId;
  final String category;
  final String city;
  final String locationName;
  final String? address;
  final DateTime eventDate;
  final double price;
  final String currencyCode;
  final int capacity;
  final int availableTickets;
  final bool isPublished;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.categoryId,
    required this.cityId,
    required this.category,
    required this.city,
    required this.locationName,
    this.address,
    required this.eventDate,
    required this.price,
    required this.currencyCode,
    required this.capacity,
    required this.availableTickets,
    required this.isPublished,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final rawCategory = json['category'] ?? json['category_ref'];
    final rawCity = json['city'] ?? json['city_ref'];
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      categoryId:
          json['category_id'] as String? ??
          _relationId(rawCategory, 'category'),
      cityId: json['city_id'] as String? ?? _relationId(rawCity, 'city'),
      category: _relationName(rawCategory, 'category'),
      city: _relationName(rawCity, 'city'),
      locationName: json['location_name'] as String? ?? '',
      address: json['address'] as String?,
      eventDate: DateTime.parse(json['event_date'] as String),
      price: (json['price'] as num).toDouble(),
      currencyCode: json['currency_code'] as String,
      capacity: (json['capacity'] as num).toInt(),
      availableTickets: (json['available_tickets'] as num?)?.toInt() ?? 0,
      isPublished: json['is_published'] as bool? ?? true,
    );
  }

  Event toEntity() => Event(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    categoryId: categoryId,
    cityId: cityId,
    category: category,
    city: city,
    locationName: locationName,
    address: address,
    eventDate: eventDate,
    price: price,
    currencyCode: currencyCode,
    capacity: capacity,
    availableTickets: availableTickets,
    isPublished: isPublished,
  );

  static String _relationId(Object? value, String relation) {
    if (value is Map && value['id'] is String) return value['id'] as String;
    throw FormatException('$relation ID is missing from event data');
  }

  static String _relationName(Object? value, String relation) {
    if (value is String) return value;
    if (value is Map && value['name'] is String) return value['name'] as String;
    throw FormatException('$relation name is missing from event data');
  }
}
