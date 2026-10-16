import 'package:eventix/data/datasources/auth_user_datasource_impl.dart';
import 'package:eventix/data/repositories/auth_user_repository_impl.dart';
import 'package:eventix/domain/entities/user.dart' as domain;
import 'package:eventix/domain/repositories/auth_user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authUserRepositoryProvider = Provider<AuthUserRepository>((ref) {
  return AuthUserRepositoryImpl(
    authUserDatasource: AuthUserDatasourceImpl(
      client: ref.watch(supabaseClientProvider),
    ),
  );
});

final authActionProvider =
    NotifierProvider<AuthActionNotifier, AsyncValue<domain.User?>>(
      AuthActionNotifier.new,
    );

class AuthActionNotifier extends Notifier<AsyncValue<domain.User?>> {
  @override
  AsyncValue<domain.User?> build() => const AsyncData(null);

  Future<domain.User?> signIn(String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authUserRepositoryProvider)
          .signIn(email, password);
      if (user == null) {
        throw const AuthRepositoryException(
          'No fue posible iniciar sesión. Inténtalo de nuevo.',
        );
      }
      state = AsyncData(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<domain.User?> signUp({
    required String email,
    required String name,
    required String lastName,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authUserRepositoryProvider)
          .signUp(email, name, lastName, password);
      state = AsyncData(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await ref.read(authUserRepositoryProvider).logout();
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

String? authActionErrorMessage(AsyncValue<domain.User?> state) {
  if (!state.hasError) return null;
  final error = state.error;
  if (error is AuthRepositoryException) return error.userMessage;
  return 'No fue posible completar la operación. Inténtalo de nuevo.';
}

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseClientProvider).auth.onAuthStateChange;
});

final currentAuthUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(supabaseClientProvider).auth.currentUser?.id;
});
