import 'package:eventix/data/datasources/auth_user_datasource.dart';
import 'package:eventix/data/models/user_model.dart';
import 'package:eventix/data/repositories/auth_user_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class _FakeAuthDatasource implements AuthUserDatasource {
  String? email;
  String? password;
  String? name;
  String? lastName;
  String? requestedUserId;
  UserModel? result = _userModel();
  Object? error;
  var logoutCalls = 0;

  @override
  Future<UserModel?> signIn(String email, String password) async {
    this.email = email;
    this.password = password;
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<UserModel?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  ) async {
    this.email = email;
    this.password = password;
    this.name = name;
    this.lastName = lastName;
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<UserModel?> getCurrentUserInfo(String id) async {
    requestedUserId = id;
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    if (error != null) throw error!;
  }
}

void main() {
  group('AuthUserRepositoryImpl', () {
    test('maps sign-in profile and forwards credentials', () async {
      final datasource = _FakeAuthDatasource();

      final user = await AuthUserRepositoryImpl(authUserDatasource: datasource)
          .signIn('ana@example.com', 'password');

      expect(datasource.email, 'ana@example.com');
      expect(datasource.password, 'password');
      expect(user?.id, 'user-1');
      expect(user?.name, 'Ana');
    });

    test('returns null when sign-in has no profile/session', () async {
      final datasource = _FakeAuthDatasource()..result = null;

      final user = await AuthUserRepositoryImpl(authUserDatasource: datasource)
          .signIn('ana@example.com', 'password');

      expect(user, isNull);
    });

    test('forwards sign-up details and maps the returned user', () async {
      final datasource = _FakeAuthDatasource();

      final user = await AuthUserRepositoryImpl(authUserDatasource: datasource)
          .signUp('ana@example.com', 'Ana', 'García', 'password');

      expect(datasource.email, 'ana@example.com');
      expect(datasource.name, 'Ana');
      expect(datasource.lastName, 'García');
      expect(datasource.password, 'password');
      expect(user?.email, 'ana@example.com');
    });

    test('forwards profile lookup and maps the user', () async {
      final datasource = _FakeAuthDatasource();

      final user = await AuthUserRepositoryImpl(authUserDatasource: datasource)
          .getCurrentUserInfo('user-1');

      expect(datasource.requestedUserId, 'user-1');
      expect(user?.lastName, 'López');
    });

    test('forwards logout', () async {
      final datasource = _FakeAuthDatasource();

      await AuthUserRepositoryImpl(authUserDatasource: datasource).logout();

      expect(datasource.logoutCalls, 1);
    });

    test('maps AuthException to a safe sign-in message', () async {
      final datasource = _FakeAuthDatasource()
        ..error = const AuthException('private auth detail');

      await expectLater(
        AuthUserRepositoryImpl(authUserDatasource: datasource)
            .signIn('ana@example.com', 'wrong'),
        throwsA(
          isA<AuthRepositoryException>().having(
            (error) => error.userMessage,
            'userMessage',
            'Correo o contraseña incorrectos.',
          ),
        ),
      );
    });

    test('does not expose generic datasource details', () async {
      final datasource = _FakeAuthDatasource()
        ..error = Exception('private database detail');

      await expectLater(
        AuthUserRepositoryImpl(authUserDatasource: datasource)
            .getCurrentUserInfo('user-1'),
        throwsA(
          isA<AuthRepositoryException>()
              .having(
                (error) => error.userMessage,
                'userMessage',
                'No fue posible cargar el perfil. Inténtalo de nuevo.',
              )
              .having(
                (error) => error.toString(),
                'toString',
                isNot(contains('private database detail')),
              ),
        ),
      );
    });

    test('maps sign-up and logout failures to safe messages', () async {
      final datasource = _FakeAuthDatasource()
        ..error = const AuthException('private auth detail');
      final repository = AuthUserRepositoryImpl(authUserDatasource: datasource);

      await expectLater(
        repository.signUp('ana@example.com', 'Ana', 'López', 'password'),
        throwsA(
          isA<AuthRepositoryException>().having(
            (error) => error.userMessage,
            'userMessage',
            'No fue posible crear la cuenta. Verifica el correo e inténtalo de nuevo.',
          ),
        ),
      );

      await expectLater(
        repository.logout(),
        throwsA(
          isA<AuthRepositoryException>().having(
            (error) => error.userMessage,
            'userMessage',
            'No fue posible cerrar sesión. Inténtalo de nuevo.',
          ),
        ),
      );
    });
  });
}

UserModel _userModel() => const UserModel(
  id: 'user-1',
  name: 'Ana',
  lastName: 'López',
  email: 'ana@example.com',
);
