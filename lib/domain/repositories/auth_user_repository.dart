import 'package:eventix/domain/entities/user.dart';

abstract class AuthUserRepository {
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  );

  Future<void> logout();
  Future<User?> getCurrentUserInfo(String id);
}
