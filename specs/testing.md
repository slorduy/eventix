# Estrategia y estado de pruebas — Eventix

## Objetivo

Proteger los comportamientos críticos del usuario con pruebas por capa y mantener al menos **80% de cobertura de líneas** del código de `lib/`. La cobertura se obtiene de `flutter test --coverage`; las pruebas nunca deben conectarse a producción.

## Qué se prueba y por qué

| Área crítica | Pruebas | Motivo |
|---|---|---|
| Dominio y filtros | `test/domain/` | Los filtros combinan UUIDs de categoría/ciudad y fechas inclusivas; una regresión puede ocultar eventos válidos. |
| Modelos y repositorios | `test/data/` | Protegen la conversión entre filas/backend y entidades, los filtros enviados, ownership y errores seguros. |
| Autenticación | `test/data/auth_user_repository_test.dart`, `test/presentation/auth_flow_test.dart` | Verifican traducción de errores, mapping del perfil y el comportamiento visible de login/registro. |
| Catálogo y filtros | `test/presentation/home_screen_test.dart`, `event_filters_test.dart` | Verifican carga de eventos, selects del catálogo, aplicación de filtros, vacío y errores de opciones. |
| Reserva | `test/presentation/event_detail_screen_test.dart`, `booking_confirmation_screen_test.dart`, `booking_confirmation_provider_test.dart` | Protegen cantidad disponible, total, confirmación y reintento idempotente. |
| Reservas/tickets | `test/presentation/booking_screens_test.dart` | Comprueban que se presentan las reservas y tickets del usuario esperado. |
| Navegación y estados | `test/core/app_routes_test.dart`, `test/presentation/async_state_view_test.dart`, `logout_action_test.dart` | Protegen deep links, carga/error/vacío y salida de sesión. |
| Recorrido integrado | `integration_test/critical_user_flows_test.dart` | Comprueba que login, catálogo, detalle, reserva y consulta de la reserva funcionan conectados entre sí. |

## Diseño de pruebas

- Los unit tests usan fakes para datasources/repositorios y no requieren red.
- Los widget tests montan pantallas/componentes reales y sustituyen providers por repositorios fake.
- La integración recorre widgets y navegación reales con repositorios fake; valida el recorrido de la app, no políticas RLS ni la disponibilidad del proyecto Supabase remoto.
- Los componentes `app_ui_kit` se prueban en el contexto en que Eventix los usa (select, loader, mensajes, botones y estados vacíos); no se duplican pruebas internas del paquete de diseño externo.
- Pruebas remotas de Auth/RLS/concurrencia son smoke tests separados y requieren un proyecto aislado y cuentas de prueba confirmadas.

## Comandos

```sh
flutter analyze
flutter test
flutter test integration_test/critical_user_flows_test.dart -d <dispositivo>
flutter test --coverage
```

`coverage/lcov.info` está ignorado por Git. La cobertura se calcula sobre líneas de `lib/`, excluyendo dependencias y tests. La suite de integración se ejecuta por separado en el dispositivo porque `flutter test --coverage` solo ejecuta `test/`.

## Resultado de ejecución

- `flutter analyze`: sin problemas.
- `flutter test`: 80 pruebas aprobadas.
- `flutter test integration_test/critical_user_flows_test.dart -d C41C8124-7F7B-4901-9A5C-49FA94D3E6A8`: 1 prueba integrada aprobada en simulador iOS; recorre login, catálogo, detalle, reserva, Mis reservas y regreso a Home con disponibilidad actualizada.
- `flutter test --coverage`: suite aprobada; 996 de 1219 líneas cubiertas en 60 archivos Dart de `lib/`, **81.71%**.
- El reporte no incluye la prueba de integración en el porcentaje; la integración se ejecutó aparte y no utiliza Supabase remoto.
