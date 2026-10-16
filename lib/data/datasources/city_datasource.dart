import 'package:eventix/data/models/city_model.dart';

abstract class CityDatasource {
  Future<List<CityModel>> getActiveCities();
}
