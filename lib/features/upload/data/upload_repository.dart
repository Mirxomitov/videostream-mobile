import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/network/failure.dart';
import 'upload_response.dart';

class UploadRepository {
  UploadRepository(this._dio);
  final Dio _dio;
  Future<UploadResponse> create(String title, String? description) async {
    try {
      final r = await _dio.post(
        '/videos/upload',
        data: {
          'title': title,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return UploadResponse.fromJson(r.data);
    } catch (e) {
      throw Failure.from(e);
    }
  }

  Future<void> putFile(
    String url,
    File file,
    void Function(int, int) progress,
  ) async {
    try {
      await _dio.put(
        url,
        data: file.openRead(),
        options: Options(
          headers: {
            'Content-Type': 'video/mp4',
            'Content-Length': '${await file.length()}',
          },
          contentType: 'video/mp4',
        ),
        onSendProgress: progress,
      );
    } catch (e) {
      throw Failure.from(e);
    }
  }
}
