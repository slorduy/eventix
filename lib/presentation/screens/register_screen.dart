import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/core/routes/route_destinations.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/widgets/register_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerWidget {
  final String? redirectTo;

  const RegisterScreen({super.key, this.redirectTo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAction = ref.watch(authActionProvider);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: RegisterForm(
            isLoading: authAction.isLoading,
            errorMessage: authActionErrorMessage(authAction),
            onSubmit:
                ({
                  required email,
                  required name,
                  required lastName,
                  required password,
                }) async {
                  final user = await ref
                      .read(authActionProvider.notifier)
                      .signUp(
                        email: email,
                        name: name,
                        lastName: lastName,
                        password: password,
                      );
                  if (!context.mounted ||
                      ref.read(authActionProvider).hasError) {
                    return;
                  }

                  if (user == null) {
                    context.go(
                      Uri(
                        path: '/sign-in',
                        queryParameters: redirectTo == null
                            ? null
                            : {'from': redirectTo},
                      ).toString(),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cuenta creada. Revisa tu correo para confirmarla.',
                        ),
                      ),
                    );
                    return;
                  }

                  context.go(postLoginDestination(redirectTo));
                },
            onLogin: () => context.go(
              Uri(
                path: '/sign-in',
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
