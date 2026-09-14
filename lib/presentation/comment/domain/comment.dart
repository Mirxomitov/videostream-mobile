class VideoComment {
  const VideoComment({
    required this.id,
    required this.text,
    required this.createdAt,
  });
  final String id, text;
  final DateTime? createdAt;

  factory VideoComment.fromJson(Map<String, dynamic> json) => VideoComment(
    id: json['_id'] as String,
    text: json['text'] as String,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
  );
}
