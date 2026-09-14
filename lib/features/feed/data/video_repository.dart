import 'package:dio/dio.dart';
import '../domain/video.dart';
import '../../../core/network/failure.dart';

class VideoRepository {
  VideoRepository(this._dio);
  final Dio _dio;
  Future<List<Video>> list() async {
    try {
      final r = await _dio.get('/videos');
      return (r.data as List).map((e) => Video.fromJson(e)).toList();
    } catch (e) {
      throw Failure.from(e);
    }
  }
}
