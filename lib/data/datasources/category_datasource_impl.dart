import 'package:eventix/data/datasources/category_datasource.dart';
import 'package:eventix/data/models/category_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryDatasourceImpl implements CategoryDatasource {
  final SupabaseClient client;

  const CategoryDatasourceImpl({required this.client});

  @override
  Future<List<CategoryModel>> getActiveCategories() async {
    final rows = await client
        .from('categories')
        .select('id,name,is_active')
        .eq('is_active', true)
        .order('name');

    return rows
        .map((row) => CategoryModel.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}
