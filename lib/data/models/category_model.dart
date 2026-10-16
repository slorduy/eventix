import 'package:eventix/domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as String,
    name: json['name'] as String,
    isActive: json['is_active'] as bool? ?? true,
  );

  Category toEntity() => Category(id: id, name: name, isActive: isActive);
}
