import 'package:dio/dio.dart';
import '../../../core/api/failure.dart';
import '../domain/auth_models.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final Dio _dio;
  Future<void> requestOtp(String phone) async {
    try {
      await _dio.post('/auth/otp', data: {'phone': phone});
    } catch (e) {
      throw Failure.from(e);
    }
  }

  Future<LoginResponse> login(String phone, String code) async {
    try {
      final r = await _dio.post(
        '/auth/login',
        data: {'phone': phone, 'code': code},
      );
      return LoginResponse.fromJson(r.data);
    } catch (e) {
      throw Failure.from(e);
    }
  }
}
