import 'package:dio/dio.dart';
import '../domain/video.dart';
import '../../../core/network/failure.dart';

class VideoRepository {
  VideoRepository(this._dio);
  final Dio _dio;
  Future<VideoPage> list({String? before}) async {
    try {
      final query = <String, dynamic>{'limit': 20};
      if (before != null) query['before'] = before;
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
}

class VideoPage {
  const VideoPage({required this.items, required this.nextCursor});
  final List<Video> items;
  final String? nextCursor;
}
