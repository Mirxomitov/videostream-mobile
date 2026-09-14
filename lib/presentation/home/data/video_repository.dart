import 'package:dio/dio.dart';
import '../domain/video.dart';
import '../../../core/api/failure.dart';

class VideoRepository {
  VideoRepository(this._dio);
  final Dio _dio;
  Future<VideoPage> list({
    String? before,
    String? category,
    String? tag,
    String? searchQuery,
  }) async {
    try {
      final query = <String, dynamic>{'limit': 20};
      if (before != null) query['before'] = before;
      if (category != null) query['category'] = category;
      if (tag != null) query['tag'] = tag;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query['q'] = searchQuery;
      }
      final r = await _dio.get('/videos', queryParameters: query);
      final data = r.data as Map<String, dynamic>;
      return VideoPage(
        items: (data['items'] as List)
            .map((e) => Video.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextCursor: data['next_cursor'] as String?,
      );
    } catch (e) {
      throw Failure.from(e);
    }
  }

  Future<List<String>> categories() async {
    final response = await _dio.get('/videos/categories');
    return (response.data as List).cast<String>()..sort();
  }

  Future<List<String>> tags() async {
    final response = await _dio.get('/videos/tags');
    return (response.data as List).cast<String>()..sort();
  }

  Future<int> like(String videoId) async {
    final response = await _dio.post('/videos/$videoId/like');
    return (response.data['likes_count'] as num).toInt();
  }

  Future<int> unlike(String videoId) async {
    final response = await _dio.delete('/videos/$videoId/like');
    return (response.data['likes_count'] as num).toInt();
  }

  Future<void> recordView(String videoId) =>
      _dio.post('/videos/$videoId/views');

  Future<void> saveHistory(String videoId, double seconds) => _dio.post(
    '/videos/$videoId/history',
    data: {'position_seconds': seconds},
  );
}

class VideoPage {
  const VideoPage({required this.items, required this.nextCursor});
  final List<Video> items;
  final String? nextCursor;
}
