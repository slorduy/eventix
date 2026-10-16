import 'package:eventix/data/datasources/category_datasource.dart';
import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/repositories/category_repository.dart';

class CategoryRepositoryException implements Exception {
  final String userMessage;

  const CategoryRepositoryException(this.userMessage);

  @override
  String toString() => userMessage;
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource datasource;

  const CategoryRepositoryImpl({required this.datasource});

  @override
  Future<List<Category>> getActiveCategories() async {
    try {
      final models = await datasource.getActiveCategories();
      return models.map((model) => model.toEntity()).toList(growable: false);
    } catch (_) {
      throw const CategoryRepositoryException(
        'No fue posible cargar las categorías. Inténtalo de nuevo.',
      );
    }
  }
}
