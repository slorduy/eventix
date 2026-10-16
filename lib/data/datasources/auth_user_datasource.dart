import 'package:eventix/data/models/user_model.dart';

abstract class AuthUserDatasource {
  Future<UserModel?> signIn(String email, String password);
  Future<UserModel?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  );
  Future<UserModel?> getCurrentUserInfo(String id);
  Future<void> logout();
}
