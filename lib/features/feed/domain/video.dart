class Video {
  const Video({
    required this.id,
    required this.title,
    this.description,
    this.hlsUrl,
    this.thumbnailUrl,
    this.duration,
    this.muxPlaybackId,
  });
  final String id, title;
  final String? description, hlsUrl, thumbnailUrl, muxPlaybackId;
  final double? duration;
  String? get playbackUrl =>
      hlsUrl ??
      (muxPlaybackId == null
          ? null
          : 'https://stream.mux.com/$muxPlaybackId.m3u8');
  factory Video.fromJson(Map<String, dynamic> j) => Video(
    id: j['_id'] as String,
    title: j['title'] as String? ?? 'Untitled',
    description: j['description'] as String?,
    hlsUrl: j['hls_url'] as String?,
    thumbnailUrl: j['thumbnail_url'] as String?,
    duration: (j['duration'] as num?)?.toDouble(),
    muxPlaybackId: j['mux_playback_id'] as String?,
  );
}
