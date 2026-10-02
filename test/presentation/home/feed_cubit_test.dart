import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:videostream_mobile/presentation/home/cubit/feed_cubit.dart';
import 'package:videostream_mobile/presentation/home/data/video_repository.dart';
import 'package:videostream_mobile/presentation/home/domain/video.dart';

class FakeVideoRepository extends VideoRepository {
  FakeVideoRepository() : super(Dio());

  final listCalls = <Map<String, String?>>[];
  var pages = <VideoPage>[];
  var likedCount = 0;
  var unlikedCount = 0;

  @override
  Future<VideoPage> list({String? before, String? category, String? tag, String? searchQuery}) async {
    listCalls.add({'before': before, 'category': category, 'tag': tag, 'searchQuery': searchQuery});
    return pages.removeAt(0);
  }

  @override
  Future<List<String>> categories() async => ['education'];

  @override
  Future<List<String>> tags() async => ['nestjs'];

  @override
  Future<int> like(String videoId) async => likedCount;

  @override
  Future<int> unlike(String videoId) async => unlikedCount;
}

const firstVideo = Video(id: 'one', title: 'First');
const secondVideo = Video(id: 'two', title: 'Second');

void main() {
  late FakeVideoRepository repository;
  late FeedCubit cubit;

  setUp(() {
    repository = FakeVideoRepository();
    cubit = FeedCubit(repository);
  });

  tearDown(() => cubit.close());

  test('loads the first feed page together with categories and tags', () async {
    repository.pages = [const VideoPage(items: [firstVideo], nextCursor: 'cursor-1')];

    await cubit.load();

    expect(cubit.state, isA<FeedLoaded>());
    final state = cubit.state as FeedLoaded;
    expect(state.videos, [firstVideo]);
    expect(state.nextCursor, 'cursor-1');
    expect(state.categories, ['education']);
    expect(state.tags, ['nestjs']);
  });

  test('uses the returned cursor and appends the next page', () async {
    repository.pages = [
      const VideoPage(items: [firstVideo], nextCursor: 'cursor-1'),
      const VideoPage(items: [secondVideo], nextCursor: null),
    ];

    await cubit.load();
    await cubit.loadMore();

    final state = cubit.state as FeedLoaded;
    expect(state.videos, [firstVideo, secondVideo]);
    expect(state.nextCursor, isNull);
    expect(repository.listCalls.last['before'], 'cursor-1');
  });

  test('trims a new search query before reloading with the selected filters', () async {
    repository.pages = [const VideoPage(items: [], nextCursor: null)];

    await cubit.setFilters(category: 'education', tag: 'nestjs', query: '  HLS  ');

    expect(repository.listCalls.single, {
      'before': null,
      'category': 'education',
      'tag': 'nestjs',
      'searchQuery': 'HLS',
    });
  });

  test('updates the displayed like count only after the API succeeds', () async {
    repository.pages = [const VideoPage(items: [firstVideo], nextCursor: null)];
    repository.likedCount = 7;
    await cubit.load();

    await cubit.toggleLike(firstVideo);

    final state = cubit.state as FeedLoaded;
    expect(state.videos.single.likesCount, 7);
    expect(cubit.isLiked(firstVideo.id), isTrue);
  });
}
