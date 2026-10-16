import 'package:eventix/data/datasources/auth_user_datasource.dart';
import 'package:eventix/domain/entities/user.dart';
import 'package:eventix/domain/repositories/auth_user_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class AuthRepositoryException implements Exception {
  final String userMessage;

  const AuthRepositoryException(this.userMessage);

  @override
  String toString() => userMessage;
}

class AuthUserRepositoryImpl implements AuthUserRepository {
  final AuthUserDatasource authUserDatasource;

  const AuthUserRepositoryImpl({required this.authUserDatasource});

  @override
  Future<User?> signIn(String email, String password) async {
    try {
      final userModel = await authUserDatasource.signIn(email, password);
      return userModel?.toEntity();
    } on AuthException {
      throw const AuthRepositoryException('Correo o contraseña incorrectos.');
    } catch (_) {
      throw const AuthRepositoryException(
        'No fue posible iniciar sesión. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<User?> getCurrentUserInfo(String id) async {
    try {
      final userModel = await authUserDatasource.getCurrentUserInfo(id);
      return userModel?.toEntity();
    } catch (_) {
      throw const AuthRepositoryException(
        'No fue posible cargar el perfil. Inténtalo de nuevo.',
      );
    }
  }

  @override
  Future<void> logout() {
    return authUserDatasource.logout().catchError((_) {
      throw const AuthRepositoryException(
        'No fue posible cerrar sesión. Inténtalo de nuevo.',
      );
    });
  }

  @override
  Future<User?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  ) async {
    try {
      final userModel = await authUserDatasource.signUp(
        email,
        name,
        lastName,
        password,
      );
      return userModel?.toEntity();
    } on AuthException {
      throw const AuthRepositoryException(
        'No fue posible crear la cuenta. Verifica el correo e inténtalo de nuevo.',
      );
    } catch (_) {
      throw const AuthRepositoryException(
        'No fue posible crear la cuenta. Inténtalo de nuevo.',
      );
    }
  }
}
