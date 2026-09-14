class Video {
  const Video({
    required this.id,
    required this.title,
    this.description,
    this.hlsUrl,
    this.thumbnailUrl,
    this.duration,
    this.category,
    this.tags = const [],
    this.likesCount = 0,
    this.viewsCount = 0,
  });
  final String id, title;
  final String? description, hlsUrl, thumbnailUrl, category;
  final double? duration;
  final List<String> tags;
  final int likesCount, viewsCount;
  String? get playbackUrl => hlsUrl;

  Video copyWith({int? likesCount, int? viewsCount}) => Video(
    id: id,
    title: title,
    description: description,
    hlsUrl: hlsUrl,
    thumbnailUrl: thumbnailUrl,
    duration: duration,
    category: category,
    tags: tags,
    likesCount: likesCount ?? this.likesCount,
    viewsCount: viewsCount ?? this.viewsCount,
  );
  factory Video.fromJson(Map<String, dynamic> j) => Video(
    id: j['_id'] as String,
    title: j['title'] as String? ?? 'Untitled',
    description: j['description'] as String?,
    hlsUrl: j['hls_url'] as String?,
    thumbnailUrl: j['thumbnail_url'] as String?,
    duration: (j['duration'] as num?)?.toDouble(),
    category: j['category'] as String?,
    tags: (j['tags'] as List? ?? const []).cast<String>(),
    likesCount: (j['likes_count'] as num?)?.toInt() ?? 0,
    viewsCount: (j['views_count'] as num?)?.toInt() ?? 0,
  );
}
