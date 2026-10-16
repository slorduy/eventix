import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/event.dart';
import 'package:eventix/presentation/providers/event_providers.dart';
import 'package:eventix/presentation/widgets/async_state_view.dart';
import 'package:eventix/presentation/widgets/event_detail_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ref.watch(eventDetailProvider(eventId));
    return Scaffold(
      appBar: AppBar(title: const AppText.titleMedium('Detalle del evento')),
      body: SafeArea(
        child: AsyncStateView<Event>(
          value: event,
          onRetry: () => ref.invalidate(eventDetailProvider(eventId)),
          builder: (value) => EventDetailContent(event: value),
        ),
      ),
    );
  }
}
