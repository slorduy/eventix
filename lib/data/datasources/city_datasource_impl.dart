import 'package:eventix/data/datasources/city_datasource.dart';
import 'package:eventix/data/models/city_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CityDatasourceImpl implements CityDatasource {
  final SupabaseClient client;

  const CityDatasourceImpl({required this.client});

  @override
  Future<List<CityModel>> getActiveCities() async {
    final rows = await client
        .from('cities')
        .select('id,name,country_code,is_active')
        .eq('is_active', true)
        .order('name');

    return rows
        .map((row) => CityModel.fromJson(Map<String, dynamic>.from(row)))
        .toList(growable: false);
  }
}
