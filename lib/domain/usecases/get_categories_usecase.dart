import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/repositories/category_repository.dart';

class GetCategoriesUsecase {
  final CategoryRepository repository;

  const GetCategoriesUsecase({required this.repository});

  Future<List<Category>> call() => repository.getActiveCategories();
}
