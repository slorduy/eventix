import 'package:eventix/domain/entities/user.dart';
import 'package:eventix/domain/repositories/auth_user_repository.dart';
import 'package:eventix/data/repositories/auth_user_repository_impl.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/screens/login_screen.dart';
import 'package:eventix/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _FakeAuthRepository implements AuthUserRepository {
  final bool successfulSignIn;
  bool signupCalled = false;

  _FakeAuthRepository({this.successfulSignIn = false});

  @override
  Future<User?> signIn(String email, String password) async {
    if (successfulSignIn) {
      return const User(
        id: 'user-1',
        name: 'Ana',
        lastName: 'García',
        email: 'ana@example.com',
      );
    }
    throw const AuthRepositoryException('Correo o contraseña incorrectos.');
  }

  @override
  Future<User?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  ) async {
    signupCalled = true;
    return null; // Simulates email confirmation pending.
  }

  @override
  Future<User?> getCurrentUserInfo(String id) async => null;

  @override
  Future<void> logout() async {}
}

void main() {
  testWidgets('shows a safe sign-in error from the auth provider', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'person@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Iniciar Sesion'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.textContaining('Correo o contraseña incorrectos.'),
      findsOneWidget,
    );
  });

  testWidgets('completes signup when email confirmation is pending', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository();
    final router = GoRouter(
      initialLocation: '/sign-up',
      routes: [
        GoRoute(
          path: '/sign-up',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/sign-in',
          builder: (context, state) =>
              const Scaffold(body: Text('Login destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Ana');
    await tester.enterText(fields.at(1), 'García');
    await tester.enterText(fields.at(2), 'ana@example.com');
    await tester.enterText(fields.at(3), 'password123');
    await tester.enterText(fields.at(4), 'password123');
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -320),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Crear cuenta'));
    await tester.pumpAndSettle();

    expect(authRepository.signupCalled, isTrue);
    expect(find.text('Login destination'), findsOneWidget);
    expect(
      find.text('Cuenta creada. Revisa tu correo para confirmarla.'),
      findsOneWidget,
    );
  });

  testWidgets('returns to the original protected deep link after sign-in', (
    tester,
  ) async {
    final authRepository = _FakeAuthRepository(successfulSignIn: true);
    final router = GoRouter(
      initialLocation: '/sign-in?from=%2Fevents%2Fevent-1',
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) =>
              LoginScreen(redirectTo: state.uri.queryParameters['from']),
        ),
        GoRoute(
          path: '/events/:eventId',
          builder: (context, state) =>
              const Scaffold(body: Text('Original event')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authUserRepositoryProvider.overrideWithValue(authRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ana@example.com');
    await tester.enterText(fields.at(1), 'password123');
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -260),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Iniciar Sesion'));
    await tester.pumpAndSettle();

    expect(find.text('Original event'), findsOneWidget);
  });
}
