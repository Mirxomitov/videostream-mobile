class UploadResponse {
  const UploadResponse(this.videoId, this.uploadUrl);
  final String videoId, uploadUrl;
  factory UploadResponse.fromJson(Map<String, dynamic> j) =>
      UploadResponse(j['video_id'] as String, j['upload_url'] as String);
}
