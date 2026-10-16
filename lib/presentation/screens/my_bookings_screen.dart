import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/booking.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/providers/booking_providers.dart';
import 'package:eventix/presentation/widgets/async_state_view.dart';
import 'package:eventix/presentation/widgets/booking_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentAuthUserIdProvider);
    if (userId == null) {
      return const Scaffold(
        body: AppEmptyState.error(
          title: 'Sesión requerida',
          description: 'Inicia sesión para consultar tus reservas.',
        ),
      );
    }

    final bookings = ref.watch(userBookingsProvider(userId));
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Volver',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const AppText.titleLarge('Mis reservas'),
      ),
      body: AsyncStateView<List<Booking>>(
        value: bookings,
        onRetry: () => ref.invalidate(userBookingsProvider(userId)),
        isEmpty: (items) => items.isEmpty,
        emptyTitle: 'Aún no tienes reservas',
        emptyDescription:
            'Explora los eventos y reserva tus entradas favoritas.',
        emptyActionLabel: 'Explorar eventos',
        onEmptyAction: () => context.go('/home'),
        builder: (items) => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) => BookingCard(
            booking: items[index],
            onTap: () => context.push('/bookings/${items[index].id}'),
          ),
        ),
      ),
    );
  }
}
