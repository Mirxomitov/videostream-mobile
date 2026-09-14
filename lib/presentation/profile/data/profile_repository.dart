import 'package:dio/dio.dart';
import '../../../core/api/failure.dart';
import '../../home/domain/video.dart';

class ProfileData {
  const ProfileData({
    required this.id,
    this.fullName,
    this.phone,
    this.history = const [],
    this.uploads = const [],
  });
  final String id;
  final String? fullName, phone;
  final List<Video> history;
  final List<Video> uploads;
}

class ProfileRepository {
  ProfileRepository(this._dio);
  final Dio _dio;

  Future<ProfileData> me() async {
    try {
      final profile =
          (await _dio.get('/users/me')).data as Map<String, dynamic>;
      final historyResponse =
          (await _dio.get('/users/me/history')).data as List;
      final uploadsResponse =
          (await _dio.get('/users/${profile['_id']}/videos')).data as List;
      return ProfileData(
        id: profile['_id'] as String,
        fullName: profile['full_name'] as String?,
        phone: profile['phone'] as String?,
        history: historyResponse
            .map((item) => item['video_id'])
            .whereType<Map<String, dynamic>>()
            .map(Video.fromJson)
            .toList(),
        uploads: uploadsResponse
            .map((item) => Video.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (error) {
      throw Failure.from(error);
    }
  }

  Future<void> updateName(String fullName) =>
      _dio.patch('/users/me', data: {'full_name': fullName});
}
