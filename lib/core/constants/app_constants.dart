import 'dart:io';

class AppConstants {
  static const tokenKey = 'access_token';
  static String get baseUrl =>
      Platform.isAndroid ? 'http://10.0.2.2:3000' : 'http://localhost:3000';
}
