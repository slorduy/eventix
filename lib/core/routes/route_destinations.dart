String postLoginDestination(String? destination) =>
    _safeLocalDestination(destination) ?? '/home';

String? _safeLocalDestination(String? destination) {
  if (destination == null ||
      !destination.startsWith('/') ||
      destination.startsWith('//')) {
    return null;
  }
  return destination;
}
