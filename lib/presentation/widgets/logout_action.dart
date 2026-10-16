import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutAction extends ConsumerWidget {
  const LogoutAction({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAction = ref.watch(authActionProvider);
    if (authAction.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Center(child: AppLoader.small()),
      );
    }

    return IconButton(
      tooltip: 'Cerrar sesión',
      onPressed: () async {
        await ref.read(authActionProvider.notifier).signOut();
        if (!context.mounted) return;
        final errorMessage = authActionErrorMessage(
          ref.read(authActionProvider),
        );
        if (errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      },
      icon: const Icon(Icons.logout),
    );
  }
}
