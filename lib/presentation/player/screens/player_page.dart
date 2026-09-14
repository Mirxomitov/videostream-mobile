import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../home/domain/video.dart';
import '../../../core/di/service_locator.dart';
import '../../home/data/video_repository.dart';
import '../../comment/screens/comments_page.dart';

@RoutePage()
class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key, required this.video});
  final Video video;
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  VideoPlayerController? videoController;
  ChewieController? chewieController;
  String? error;
  @override
  void initState() {
    super.initState();
    unawaited(sl<VideoRepository>().recordView(widget.video.id));
    _init();
  }

  Future<void> _init() async {
    final url = widget.video.playbackUrl;
    if (url == null) {
      setState(() => error = 'Video playback URL unavailable.');
      return;
    }
    try {
      final c = VideoPlayerController.networkUrl(Uri.parse(url));
      await c.initialize();
      if (!mounted) {
        c.dispose();
        return;
      }
      videoController = c;
      chewieController = ChewieController(
        videoPlayerController: c,
        autoPlay: true,
        allowFullScreen: true,
        showControls: true,
      );
      setState(() {});
    } catch (_) {
      if (mounted) setState(() => error = 'Could not load video.');
    }
  }

  @override
  void dispose() {
    final position = videoController?.value.position.inSeconds.toDouble() ?? 0;
    if (position > 0) {
      unawaited(sl<VideoRepository>().saveHistory(widget.video.id, position));
    }
    chewieController?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.video.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.comment_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CommentsPage(videoId: widget.video.id),
            ),
          ),
        ),
      ],
    ),
    body: Center(
      child: error != null
          ? Text(error!)
          : chewieController == null
          ? const CircularProgressIndicator()
          : Chewie(controller: chewieController!),
    ),
  );
}
