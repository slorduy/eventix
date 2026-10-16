import 'dart:async';

import 'package:eventix/core/routes/route_destinations.dart';
import 'package:eventix/presentation/providers/auth_providers.dart';
import 'package:eventix/presentation/screens/auth_gate.dart';
import 'package:eventix/presentation/screens/home_screen.dart';
import 'package:eventix/presentation/screens/event_detail_screen.dart';
import 'package:eventix/presentation/screens/booking_confirmation_screen.dart';
import 'package:eventix/presentation/screens/booking_detail_screen.dart';
import 'package:eventix/presentation/screens/my_bookings_screen.dart';
import 'package:eventix/presentation/screens/login_screen.dart';
import 'package:eventix/presentation/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final refreshListenable = GoRouterRefreshStream(
    client.auth.onAuthStateChange,
  );

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) => resolveAppRedirect(
      hasSession: client.auth.currentSession != null,
      uri: state.uri,
    ),
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AuthGate()),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) =>
            LoginScreen(redirectTo: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) =>
            RegisterScreen(redirectTo: state.uri.queryParameters['from']),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/events/:eventId',
        builder: (context, state) =>
            EventDetailScreen(eventId: state.pathParameters['eventId']!),
      ),
      GoRoute(
        path: '/events/:eventId/confirmation',
        builder: (context, state) => BookingConfirmationScreen(
          eventId: state.pathParameters['eventId']!,
          quantity:
              int.tryParse(state.uri.queryParameters['quantity'] ?? '') ?? 1,
        ),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: '/bookings/:bookingId',
        builder: (context, state) =>
            BookingDetailScreen(bookingId: state.pathParameters['bookingId']!),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refreshListenable.dispose();
  });

  return router;
});

/// Only internal paths are accepted as post-login destinations.
String? resolveAppRedirect({required bool hasSession, required Uri uri}) {
  final isAuthRoute = uri.path == '/sign-in' || uri.path == '/sign-up';

  if (uri.path == '/') {
    return hasSession ? '/home' : '/sign-in';
  }

  if (!hasSession && !isAuthRoute) {
    return Uri(
      path: '/sign-in',
      queryParameters: {'from': uri.toString()},
    ).toString();
  }

  if (hasSession && isAuthRoute) {
    return postLoginDestination(uri.queryParameters['from']);
  }

  return null;
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
