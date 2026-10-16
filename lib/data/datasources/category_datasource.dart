import 'package:eventix/data/models/category_model.dart';

abstract class CategoryDatasource {
  Future<List<CategoryModel>> getActiveCategories();
}
