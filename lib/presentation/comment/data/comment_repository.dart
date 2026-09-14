import 'package:dio/dio.dart';
import '../../../core/api/failure.dart';
import '../domain/comment.dart';

class CommentRepository {
  CommentRepository(this._dio);
  final Dio _dio;

  Future<List<VideoComment>> list(String videoId) async {
    try {
      final response = await _dio.get('/videos/$videoId/comments');
      return (response.data as List)
          .map((item) => VideoComment.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (error) {
      throw Failure.from(error);
    }
  }

  Future<VideoComment> create(String videoId, String text) async {
    try {
      final response = await _dio.post(
        '/videos/$videoId/comments',
        data: {'text': text},
      );
      return VideoComment.fromJson(response.data as Map<String, dynamic>);
    } catch (error) {
      throw Failure.from(error);
    }
  }
}
