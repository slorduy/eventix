import 'package:eventix/domain/entities/city.dart';

class CityModel {
  final String id;
  final String name;
  final String countryCode;
  final bool isActive;

  const CityModel({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.isActive,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) => CityModel(
    id: json['id'] as String,
    name: json['name'] as String,
    countryCode: (json['country_code'] as String).trim(),
    isActive: json['is_active'] as bool? ?? true,
  );

  City toEntity() =>
      City(id: id, name: name, countryCode: countryCode, isActive: isActive);
}
