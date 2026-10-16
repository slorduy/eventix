import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Backend exception details are intentionally not rendered to the user.
class AsyncStateView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final VoidCallback onRetry;
  final bool Function(T data)? isEmpty;
  final String emptyTitle;
  final String emptyDescription;
  final String emptyActionLabel;
  final VoidCallback? onEmptyAction;

  const AsyncStateView({
    super.key,
    required this.value,
    required this.builder,
    required this.onRetry,
    this.isEmpty,
    this.emptyTitle = 'No hay información',
    this.emptyDescription = 'Aún no hay datos para mostrar.',
    this.emptyActionLabel = 'Continuar',
    this.onEmptyAction,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const Center(child: AppLoader()),
      error: (_, _) => AppEmptyState.error(onAction: onRetry),
      data: (data) {
        if (isEmpty?.call(data) ?? false) {
          return AppEmptyState.noData(
            title: emptyTitle,
            description: emptyDescription,
            actionLabel: onEmptyAction == null ? null : emptyActionLabel,
            onAction: onEmptyAction,
          );
        }
        return builder(data);
      },
    );
  }
}
