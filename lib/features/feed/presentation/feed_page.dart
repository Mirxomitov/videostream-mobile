import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/router/app_router.dart';
import 'feed_bloc.dart';

@RoutePage()
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  @override
  void initState() {
    super.initState();
    context.read<FeedCubit>().load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('VideoStream'),
      actions: [
        IconButton(
          onPressed: () => context.router.push(const UploadRoute()),
          icon: const Icon(Icons.upload_file),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () => context.read<FeedCubit>().load(),
      child: BlocBuilder<FeedCubit, FeedState>(
        builder: (context, state) {
          if (state is FeedLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FeedError) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(state.message),
                ),
              ],
            );
          }
          final videos = (state as FeedLoaded).videos;
          if (videos.isEmpty) {
            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No ready videos yet.'),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: SizedBox(
                    width: 120,
                    height: 80,
                    child: video.thumbnailUrl == null
                        ? const ColoredBox(
                            color: Colors.black12,
                            child: Icon(Icons.movie),
                          )
                        : CachedNetworkImage(
                            imageUrl: video.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => const Icon(Icons.movie),
                          ),
                  ),
                  title: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(video.description ?? 'Ready to watch'),
                  onTap: () => context.router.push(PlayerRoute(video: video)),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
