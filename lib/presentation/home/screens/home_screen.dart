import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/routes/app_router.dart';
import '../cubit/feed_cubit.dart';
import '../../profile/screens/profile_page.dart';

@RoutePage()
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final scrollController = ScrollController();
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<FeedCubit>().load();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 300) {
        context.read<FeedCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('VideoStream'),
      actions: [
        IconButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage())),
          icon: const Icon(Icons.person_outline),
        ),
        IconButton(
          onPressed: () => context.router.push(const UploadRoute()),
          icon: const Icon(Icons.upload_file),
        ),
      ],
    ),
    body: BlocBuilder<FeedCubit, FeedState>(
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
        final loaded = state as FeedLoaded;
        final videos = loaded.videos;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: (query) => context.read<FeedCubit>().setFilters(
                  category: loaded.category,
                  tag: loaded.tag,
                  query: query,
                ),
                decoration: InputDecoration(
                  hintText: 'Search videos',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: () => context.read<FeedCubit>().setFilters(
                      category: loaded.category,
                      tag: loaded.tag,
                      query: searchController.text,
                    ),
                    icon: const Icon(Icons.arrow_forward),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: loaded.category == null && loaded.tag == null,
                    onSelected: (_) => context.read<FeedCubit>().setFilters(
                      query: loaded.query,
                    ),
                  ),
                  ...loaded.categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: loaded.category == category,
                        onSelected: (_) => context.read<FeedCubit>().setFilters(
                          category: loaded.category == category
                              ? null
                              : category,
                          tag: null,
                          query: loaded.query,
                        ),
                      ),
                    ),
                  ),
                  ...loaded.tags
                      .take(12)
                      .map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: FilterChip(
                            label: Text('#$tag'),
                            selected: loaded.tag == tag,
                            onSelected: (_) =>
                                context.read<FeedCubit>().setFilters(
                                  category: null,
                                  tag: loaded.tag == tag ? null : tag,
                                  query: loaded.query,
                                ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context.read<FeedCubit>().load(),
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: videos.isEmpty
                      ? 1
                      : videos.length + (loaded.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (videos.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: Text('No ready videos yet.')),
                      );
                    }
                    if (index == videos.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final video = videos[index];
                    final cubit = context.read<FeedCubit>();
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
                                  errorWidget: (_, _, _) =>
                                      const Icon(Icons.movie),
                                ),
                        ),
                        title: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${video.description ?? 'Ready to watch'} · ${video.viewsCount} views',
                        ),
                        trailing: IconButton(
                          onPressed: () => cubit.toggleLike(video),
                          icon: Icon(
                            cubit.isLiked(video.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          tooltip: '${video.likesCount} likes',
                        ),
                        onTap: () =>
                            context.router.push(PlayerRoute(video: video)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
