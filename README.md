# Eventix

Eventix es una aplicación Flutter para descubrir eventos, filtrarlos y simular la reserva de entradas. La autenticación y los datos se gestionan con Supabase. La compra es demostrativa: no hay cobros ni pasarela de pago.

## Funcionalidades

- Registro, inicio y cierre de sesión con Supabase Auth.
- Catálogo de eventos publicados con detalle, precio y disponibilidad.
- Filtros combinables por categoría, ciudad y rango de fechas. Categoría y ciudad se eligen en selects; sus opciones vienen de los catálogos de Supabase.
- Confirmación simulada de una reserva, con un ticket por entrada.
- Historial de reservas y consulta de los tickets propios.
- Estados de carga, error, catálogo vacío y filtros sin resultados.

El proyecto incluye cinco eventos ficticios publicados para demostración. Sus categorías son Música en vivo, Tecnología, Teatro, Deportes y Gastronomía; las ciudades son Bogotá, Medellín, Cali y Barranquilla.

## Capturas de pantalla

Las capturas del flujo principal están en [`screenshots/`](screenshots/):

| Inicio de sesión | Registro |
|---|---|
| <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.43%E2%80%AFPM.png" width="260" alt="Pantalla de inicio de sesión"> | <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.46%E2%80%AFPM.png" width="260" alt="Pantalla de registro"> |

| Catálogo y filtros | Detalle del evento |
|---|---|
| <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.08%E2%80%AFPM.png" width="260" alt="Catálogo de eventos y filtros"> | <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.19%E2%80%AFPM.png" width="260" alt="Detalle de un evento"> |

| Confirmación pendiente | Reserva confirmada |
|---|---|
| <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.24%E2%80%AFPM.png" width="260" alt="Resumen antes de confirmar la reserva"> | <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.29%E2%80%AFPM.png" width="260" alt="Reserva confirmada con acciones para continuar"> |

| Mis reservas | Detalle de reserva y tickets |
|---|---|
| <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.33%E2%80%AFPM.png" width="260" alt="Lista de reservas del usuario"> | <img src="screenshots/Screenshot%20iPhone%2016%20Pro%2016-10-2026%20at%2012.36.36%E2%80%AFPM.png" width="260" alt="Detalle de reserva con tickets"> |

## Arquitectura

El código mantiene una separación por capas:

```text
lib/
├── core/          # Rutas, validadores y utilidades
├── data/          # Datasources, modelos y repositorios Supabase
├── domain/        # Entidades, contratos y casos de uso
└── presentation/  # Pantallas, widgets y providers Riverpod
```

- **Presentation:** las pantallas consumen providers; no acceden directamente a Supabase.
- **Domain:** contiene modelos y reglas de negocio independientes de Flutter y del backend.
- **Data:** implementa los contratos de dominio y transforma filas de Supabase a entidades.
- **Estado:** Riverpod 3 administra sesión, catálogos, eventos, filtros, reservas y estados asíncronos.
- **Navegación:** `go_router` protege las rutas privadas y conserva destinos internos al iniciar sesión.
- **Diseño:** se reutiliza `app_ui_kit` para tema, colores, tipografía, formularios, selects y estados vacíos.

## Flujos principales

1. **Autenticación:** `AuthGate` y el guard de rutas dirigen a login o al catálogo según la sesión. Si Supabase solicita confirmar el correo, la app informa que el registro se completó y permite volver a iniciar sesión.
2. **Descubrimiento:** Home carga eventos publicados y opciones activas de `categories` y `cities`. Los filtros guardan los UUID seleccionados y se combinan con AND; las fechas son inclusivas.
3. **Reserva:** el detalle permite seleccionar entradas disponibles y muestra el total. La pantalla de confirmación no solicita datos de pago.
4. **Confirmación:** la RPC `confirm_event_booking` obtiene el usuario desde `auth.uid()`, valida disponibilidad, precio y estado del evento, y crea la reserva y los tickets en una transacción. Un `request_id` permite reutilizar el resultado en reintentos.
5. **Mis reservas:** las consultas se limitan al usuario autenticado; se muestran sus reservas y tickets.

## Datos y seguridad

- `auth.users` es la identidad de Supabase; `public.users` guarda el perfil. El trigger `handle_new_user` crea el perfil a partir de los metadatos del registro.
- `public.categories` y `public.cities` contienen las opciones de los selects. Las cuentas autenticadas pueden leer solo filas activas; la app no administra estos catálogos.
- `public.events` referencia ambos catálogos por `category_id` y `city_id`. La vista `event_catalog` expone las etiquetas y disponibilidad y está configurada con `security_invoker`.
- `public.bookings` guarda propietario, evento, cantidad, estado y snapshot de precio. `public.tickets` relaciona cada entrada con su reserva.
- RLS limita los perfiles, reservas y tickets a su propietario. La escritura de reservas/tickets se realiza mediante la RPC; el cliente no decide el precio, propietario ni código del ticket.
- Las columnas de texto legacy `events.category` y `events.city` se conservan temporalmente por compatibilidad; el catálogo y los filtros nuevos usan IDs.
- Las contraseñas se gestionan con Supabase Auth. La app no lee ni escribe la columna legacy `public.users.password`.
- Nunca incluir una clave `service_role` en Flutter. La app usa una clave publicable; no guardar credenciales reales en documentación o logs.

Las migraciones de base de datos están en `supabase/migrations/`. Antes de cambiar el esquema, revisar los preflight checks de cada migración y preservar los datos existentes.

## Tecnologías

- Flutter / Dart
- `supabase_flutter`
- `flutter_riverpod` 3
- `go_router`
- `app_ui_kit` (dependencia Git, fase 4)

## Configuración y ejecución

1. Configura en `lib/main.dart` la URL del proyecto Supabase y su clave publicable. No uses una clave `service_role` en la app.
2. Instala dependencias:

   ```sh
   flutter pub get
   ```

3. Ejecuta la aplicación:

   ```sh
   flutter run
   ```

## Validación

```sh
flutter analyze
flutter test
flutter test --coverage
```

La suite de integración para login, carga de eventos y reserva se ejecuta en un simulador/dispositivo con `flutter test integration_test/critical_user_flows_test.dart -d <dispositivo>`. Las pruebas automatizadas usan fakes y no necesitan credenciales de producción. El smoke test autenticado y las pruebas de RLS con dos usuarios requieren una cuenta de prueba confirmada y un entorno de Supabase adecuado.

## Documentación del proyecto

- [`specs/spec.md`](specs/spec.md): alcance y requisitos funcionales/técnicos.
- [`specs/plan.md`](specs/plan.md): arquitectura, decisiones y fases.
- [`specs/task.md`](specs/task.md): tareas, dependencias y estado de verificación.
- [`specs/testing.md`](specs/testing.md): estrategia, alcance y resultados de pruebas/cobertura.
