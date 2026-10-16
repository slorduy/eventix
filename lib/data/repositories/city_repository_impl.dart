import 'package:eventix/data/datasources/city_datasource.dart';
import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/repositories/city_repository.dart';

class CityRepositoryException implements Exception {
  final String userMessage;

  const CityRepositoryException(this.userMessage);

  @override
  String toString() => userMessage;
}

class CityRepositoryImpl implements CityRepository {
  final CityDatasource datasource;

  const CityRepositoryImpl({required this.datasource});

  @override
  Future<List<City>> getActiveCities() async {
    try {
      final models = await datasource.getActiveCities();
      return models.map((model) => model.toEntity()).toList(growable: false);
    } catch (_) {
      throw const CityRepositoryException(
        'No fue posible cargar las ciudades. Inténtalo de nuevo.',
      );
    }
  }
}
