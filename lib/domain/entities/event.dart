class Event {
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

  const Event({
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
    this.isPublished = true,
  });
}
