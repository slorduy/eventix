import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/repositories/city_repository.dart';

class GetCitiesUsecase {
  final CityRepository repository;

  const GetCitiesUsecase({required this.repository});

  Future<List<City>> call() => repository.getActiveCities();
}
