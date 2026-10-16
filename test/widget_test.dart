import 'package:eventix/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login form displays validation errors when empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );

    await tester.tap(find.text('Iniciar Sesion'));
    await tester.pumpAndSettle();

    expect(find.text('Ingresa tu correo'), findsOneWidget);
    expect(
      find.text('La contraseña debe tener mínimo 8 caracteres'),
      findsOneWidget,
    );
  });
}
