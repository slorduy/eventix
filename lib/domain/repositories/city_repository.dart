import 'package:eventix/domain/entities/city.dart';

abstract class CityRepository {
  Future<List<City>> getActiveCities();
}
