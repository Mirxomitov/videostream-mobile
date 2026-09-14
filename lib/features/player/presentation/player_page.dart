import 'package:auto_route/auto_route.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../feed/domain/video.dart';

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
    chewieController?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.video.title)),
    body: Center(
      child: error != null
          ? Text(error!)
          : chewieController == null
          ? const CircularProgressIndicator()
          : Chewie(controller: chewieController!),
    ),
  );
}
