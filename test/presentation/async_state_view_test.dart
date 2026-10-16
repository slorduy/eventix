import 'package:eventix/presentation/widgets/async_state_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows a design-system loader while loading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AsyncStateView<int>(
          value: AsyncValue<int>.loading(),
          builder: _data,
          onRetry: _noop,
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows an error empty-state with retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        home: AsyncStateView<int>(
          value: AsyncValue<int>.error(
            Exception('private detail'),
            StackTrace.current,
          ),
          builder: _data,
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.text('Ocurrió un problema'), findsOneWidget);
    await tester.tap(find.text('Reintentar'));
    expect(retried, isTrue);
    expect(find.text('private detail'), findsNothing);
  });

  testWidgets('shows the configured empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AsyncStateView<int>(
          value: AsyncValue<int>.data(0),
          builder: _data,
          onRetry: _noop,
          isEmpty: _isZero,
          emptyTitle: 'No hay eventos',
        ),
      ),
    );

    expect(find.text('No hay eventos'), findsOneWidget);
  });
}

Widget _data(int value) => Text('Data: $value');
bool _isZero(int value) => value == 0;
void _noop() {}
