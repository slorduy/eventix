import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/widgets/async_state_view.dart';
import 'package:eventix/presentation/widgets/event_card.dart';
import 'package:eventix/presentation/widgets/event_filters.dart';
import 'package:eventix/presentation/widgets/logout_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider);
    final filter = ref.watch(eventFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const AppText.titleLarge('Eventos'),
        actions: [
          IconButton(
            tooltip: 'Mis reservas',
            onPressed: () => context.push('/bookings'),
            icon: const Icon(Icons.confirmation_number_outlined),
          ),
          const LogoutAction(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(eventsProvider);
          await ref.read(eventsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            EventFilters(
              filter: filter,
              categories: ref.watch(categoriesProvider),
              cities: ref.watch(citiesProvider),
              onApply: ref.read(eventFilterProvider.notifier).setFilter,
              onClear: ref.read(eventFilterProvider.notifier).clear,
              onRetryOptions: () {
                ref.invalidate(categoriesProvider);
                ref.invalidate(citiesProvider);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            AsyncStateView<List<Event>>(
              value: events,
              onRetry: () => ref.invalidate(eventsProvider),
              isEmpty: (items) => items.isEmpty,
              emptyTitle: filter.isEmpty
                  ? 'Aún no hay eventos'
                  : 'Sin resultados',
              emptyDescription: filter.isEmpty
                  ? 'Vuelve pronto para descubrir nuevos eventos.'
                  : 'No encontramos eventos con esos filtros.',
              emptyActionLabel: 'Limpiar filtros',
              onEmptyAction: filter.isEmpty
                  ? null
                  : ref.read(eventFilterProvider.notifier).clear,
              builder: (items) => Column(
                children: [
                  for (final event in items) ...[
                    EventCard(
                      event: event,
                      onTap: () => context.push('/events/${event.id}'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
