class AppConstants {
  static const tokenKey = 'access_token';

  // Live backend by default. Override for local dev, e.g.:
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000   (Android emulator)
  //   flutter run --dart-define=API_BASE_URL=http://localhost:3000  (iOS sim / desktop)
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://stream.medic24.tj',
  );
}
