import 'package:app_ui_kit/app_ui_kit.dart';
import 'package:eventix/domain/entities/category.dart';
import 'package:eventix/domain/entities/city.dart';
import 'package:eventix/domain/entities/event_filter.dart';
import 'package:eventix/presentation/widgets/event_filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('applies selected category and city catalog IDs', (tester) async {
    EventFilter? appliedFilter;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventFilters(
            filter: const EventFilter(),
            categories: const AsyncData([
              Category(id: 'category-theater', name: 'Teatro'),
            ]),
            cities: const AsyncData([
              City(id: 'city-cali', name: 'Cali', countryCode: 'CO'),
            ]),
            onApply: (filter) => appliedFilter = filter,
            onClear: () {},
            onRetryOptions: () {},
          ),
        ),
      ),
    );

    final selects = find.byType(AppSelect<String?>);
    await tester.tap(selects.at(0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Teatro').last);
    await tester.pumpAndSettle();

    await tester.tap(selects.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cali').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Aplicar filtros'));

    expect(appliedFilter?.categoryId, 'category-theater');
    expect(appliedFilter?.cityId, 'city-cali');
    expect(appliedFilter?.dateFrom, isNull);
    expect(appliedFilter?.dateTo, isNull);
  });

  testWidgets('shows failed catalog options and allows retry', (tester) async {
    var retryCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventFilters(
            filter: const EventFilter(),
            categories: AsyncValue.error(
              Exception('private catalog error'),
              StackTrace.current,
            ),
            cities: const AsyncData(<City>[]),
            onApply: (_) {},
            onClear: () {},
            onRetryOptions: () => retryCalls++,
          ),
        ),
      ),
    );

    expect(find.text('No se pudieron cargar las categorías'), findsOneWidget);
    expect(find.text('private catalog error'), findsNothing);

    await tester.tap(find.text('Categoría'));
    await tester.pumpAndSettle();
    expect(find.text('Seleccionar opción'), findsNothing);

    await tester.tap(find.text('Reintentar cargar filtros'));
    expect(retryCalls, 1);
  });

  testWidgets('disables a select while its catalog is loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EventFilters(
            filter: const EventFilter(),
            categories: const AsyncLoading(),
            cities: const AsyncData(<City>[]),
            onApply: (_) {},
            onClear: () {},
            onRetryOptions: () {},
          ),
        ),
      ),
    );

    expect(find.text('Cargando categorías...'), findsOneWidget);
    await tester.tap(find.text('Categoría'));
    await tester.pumpAndSettle();
    expect(find.text('Seleccionar opción'), findsNothing);
  });
}
