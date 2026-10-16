import 'package:eventix/data/datasources/auth_user_datasource.dart';
import 'package:eventix/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthUserDatasourceImpl implements AuthUserDatasource {
  final SupabaseClient? client;

  AuthUserDatasourceImpl({this.client});

  SupabaseClient get _supabase => client ?? Supabase.instance.client;

  @override
  Future<UserModel?> signIn(String email, String password) async {
    final AuthResponse authRes = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final String? userId = authRes.user?.id;

    if (userId == null || authRes.session == null) return null;

    final Map<String, dynamic> userData = await _supabase
        .from('users')
        .select('id, first_name, last_name, email')
        .eq('id', userId)
        .single();

    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  ) async {
    final AuthResponse authRes = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'first_name': name, 'last_name': lastName},
    );

    final String? userId = authRes.user?.id;

    if (userId == null || authRes.session == null) return null;

    final Map<String, dynamic> userData = await _supabase
        .from('users')
        .select('id, first_name, last_name, email')
        .eq('id', userId)
        .single();

    return UserModel.fromJson(userData);
  }

  @override
  Future<UserModel?> getCurrentUserInfo(String id) async {
    if (_supabase.auth.currentUser?.id != id) return null;

    final Map<String, dynamic> userData = await _supabase
        .from('users')
        .select('id, first_name, last_name, email')
        .eq('id', id)
        .single();

    return UserModel.fromJson(userData);
  }

  @override
  Future<void> logout() {
    return _supabase.auth.signOut();
  }
}
