import 'package:eventix/core/routes/app_routes.dart';
import 'package:eventix/core/routes/route_destinations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveAppRedirect', () {
    test('sends unauthenticated root visits to sign-in', () {
      expect(
        resolveAppRedirect(hasSession: false, uri: Uri.parse('/')),
        '/sign-in',
      );
    });

    test('sends authenticated root visits to home', () {
      expect(
        resolveAppRedirect(hasSession: true, uri: Uri.parse('/')),
        '/home',
      );
    });

    test('preserves a protected deep link for after sign-in', () {
      final redirect = resolveAppRedirect(
        hasSession: false,
        uri: Uri.parse('/events/event-1?source=featured'),
      );

      expect(redirect, startsWith('/sign-in?from='));
      expect(
        Uri.parse(redirect!).queryParameters['from'],
        '/events/event-1?source=featured',
      );
    });

    test('returns an authenticated user to an internal deep link', () {
      expect(
        resolveAppRedirect(
          hasSession: true,
          uri: Uri.parse('/sign-in?from=%2Fevents%2Fevent-1'),
        ),
        '/events/event-1',
      );
    });

    test('rejects external post-login destinations', () {
      expect(
        resolveAppRedirect(
          hasSession: true,
          uri: Uri.parse('/sign-in?from=%2F%2Fevil.example'),
        ),
        '/home',
      );
    });

    test('keeps unauthenticated users on auth routes', () {
      expect(
        resolveAppRedirect(hasSession: false, uri: Uri.parse('/sign-up')),
        isNull,
      );
    });
  });

  test('postLoginDestination accepts only internal paths', () {
    expect(postLoginDestination('/events/event-1'), '/events/event-1');
    expect(postLoginDestination('//external.example'), '/home');
    expect(postLoginDestination(null), '/home');
  });
}
