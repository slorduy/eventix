import 'dart:async';

import 'package:eventix/data/repositories/auth_user_repository_impl.dart';
import 'package:eventix/domain/entities/user.dart';
import 'package:eventix/domain/repositories/auth_user_repository.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/widgets/logout_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthUserRepository {
  final Completer<void>? logoutCompleter;
  final Object? logoutError;
  var logoutCalls = 0;

  _FakeAuthRepository({this.logoutCompleter, this.logoutError});

  @override
  Future<User?> signIn(String email, String password) async => null;

  @override
  Future<User?> signUp(
    String email,
    String name,
    String lastName,
    String password,
  ) async => null;

  @override
  Future<User?> getCurrentUserInfo(String id) async => null;

  @override
  Future<void> logout() async {
    logoutCalls++;
    if (logoutCompleter != null) await logoutCompleter!.future;
    if (logoutError != null) throw logoutError!;
  }
}

Widget _testApp(AuthUserRepository repository) => ProviderScope(
  overrides: [authUserRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    home: Scaffold(appBar: AppBar(actions: [const LogoutAction()])),
  ),
);

void main() {
  testWidgets('dispatches logout through the auth repository', (tester) async {
    final repository = _FakeAuthRepository();
    await tester.pumpWidget(_testApp(repository));

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 1);
    expect(find.byTooltip('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('shows progress and disables the action while logging out', (
    tester,
  ) async {
    final completer = Completer<void>();
    final repository = _FakeAuthRepository(logoutCompleter: completer);
    await tester.pumpWidget(_testApp(repository));

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pump();

    expect(find.byTooltip('Cerrar sesión'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pumpAndSettle();
    expect(repository.logoutCalls, 1);
  });

  testWidgets('shows a safe error and keeps logout available after failure', (
    tester,
  ) async {
    final repository = _FakeAuthRepository(
      logoutError: const AuthRepositoryException(
        'No fue posible cerrar sesión. Inténtalo de nuevo.',
      ),
    );
    await tester.pumpWidget(_testApp(repository));

    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('No fue posible cerrar sesión. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Cerrar sesión'), findsOneWidget);
  });
}
