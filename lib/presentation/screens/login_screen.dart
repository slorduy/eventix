import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/routes/route_destinations.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerWidget {
  final String? redirectTo;

  const LoginScreen({super.key, this.redirectTo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAction = ref.watch(authActionProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoginForm(
            isLoading: authAction.isLoading,
            errorMessage: authActionErrorMessage(authAction),
            onSubmit: (email, password) async {
              final user = await ref
                  .read(authActionProvider.notifier)
                  .signIn(email, password);
              if (user != null && context.mounted) {
                context.go(postLoginDestination(redirectTo));
              }
            },
            onRegister: () => context.push(
              Uri(
                path: '/sign-up',
                queryParameters: redirectTo == null
                    ? null
                    : {'from': redirectTo},
              ).toString(),
            ),
          ),
        ),
      ),
    );
  }
}
