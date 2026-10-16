import 'package:eventix/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getActiveCategories();
}
