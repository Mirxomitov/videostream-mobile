import 'package:dio/dio.dart';

class Failure implements Exception {
  const Failure(this.message);
  final String message;
  factory Failure.from(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        return Failure(data['message'].toString());
      }
      if (error.type == DioExceptionType.connectionError) {
        return const Failure('Cannot connect to server.');
      }
    }
    return const Failure('Something went wrong. Try again.');
  }
}
