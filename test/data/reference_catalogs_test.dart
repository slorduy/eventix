import 'package:eventix/data/datasources/category_datasource.dart';
import 'package:eventix/data/datasources/city_datasource.dart';
import 'package:eventix/data/models/category_model.dart';
import 'package:eventix/data/models/city_model.dart';
import 'package:eventix/data/repositories/category_repository_impl.dart';
import 'package:eventix/data/repositories/city_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeCategoryDatasource implements CategoryDatasource {
  List<CategoryModel> models = const [];

  @override
  Future<List<CategoryModel>> getActiveCategories() async => models;
}

class _FakeCityDatasource implements CityDatasource {
  List<CityModel> models = const [];

  @override
  Future<List<CityModel>> getActiveCities() async => models;
}

void main() {
  test('decodes a category and city row', () {
    final category = CategoryModel.fromJson({
      'id': 'category-1',
      'name': 'Teatro',
      'is_active': true,
    }).toEntity();
    final city = CityModel.fromJson({
      'id': 'city-1',
      'name': 'Bogotá',
      'country_code': 'CO',
      'is_active': true,
    }).toEntity();

    expect(category.id, 'category-1');
    expect(category.name, 'Teatro');
    expect(category.isActive, isTrue);
    expect(city.id, 'city-1');
    expect(city.name, 'Bogotá');
    expect(city.countryCode, 'CO');
    expect(city.isActive, isTrue);
  });

  test('maps active category rows to domain entities', () async {
    final datasource = _FakeCategoryDatasource()
      ..models = const [
        CategoryModel(id: 'category-1', name: 'Teatro', isActive: true),
      ];

    final categories = await CategoryRepositoryImpl(datasource: datasource)
        .getActiveCategories();

    expect(categories, hasLength(1));
    expect(categories.single.id, 'category-1');
    expect(categories.single.name, 'Teatro');
  });

  test('maps active city rows to domain entities', () async {
    final datasource = _FakeCityDatasource()
      ..models = const [
        CityModel(
          id: 'city-1',
          name: 'Bogotá',
          countryCode: 'CO',
          isActive: true,
        ),
      ];

    final cities = await CityRepositoryImpl(datasource: datasource)
        .getActiveCities();

    expect(cities, hasLength(1));
    expect(cities.single.id, 'city-1');
    expect(cities.single.name, 'Bogotá');
    expect(cities.single.countryCode, 'CO');
  });
}
