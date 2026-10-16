class City {
  final String id;
  final String name;
  final String countryCode;
  final bool isActive;

  const City({
    required this.id,
    required this.name,
    required this.countryCode,
    this.isActive = true,
  });
}
