import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/video_repository.dart';
import '../domain/video.dart';

sealed class FeedState extends Equatable {
  const FeedState();
  @override
  List<Object?> get props => [];
}

class FeedLoading extends FeedState {}

class FeedLoaded extends FeedState {
  const FeedLoaded(
    this.videos,
    this.nextCursor, {
    this.categories = const [],
    this.tags = const [],
    this.category,
    this.tag,
    this.query = '',
    this.isLoadingMore = false,
  });
  final List<Video> videos;
  final String? nextCursor;
  final List<String> categories, tags;
  final String? category, tag;
  final String query;
  final bool isLoadingMore;
  @override
  List<Object?> get props => [
    videos,
    nextCursor,
    categories,
    tags,
    category,
    tag,
    query,
    isLoadingMore,
  ];
}

class FeedError extends FeedState {
  const FeedError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._repo) : super(FeedLoading());
  final VideoRepository _repo;
  bool _loadingMore = false;
  String? _category, _tag;
  String _query = '';
  final Set<String> _likedVideoIds = {};

  Future<void> load() async {
    _loadingMore = false;
    emit(FeedLoading());
    try {
      final results = await Future.wait([
        _repo.list(category: _category, tag: _tag, searchQuery: _query),
        _repo.categories(),
        _repo.tags(),
      ]);
      final page = results[0] as VideoPage;
      emit(
        FeedLoaded(
          page.items,
          page.nextCursor,
          categories: results[1] as List<String>,
          tags: results[2] as List<String>,
          category: _category,
          tag: _tag,
          query: _query,
        ),
      );
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }

  Future<void> loadMore() async {
    final current = state;
    if (current is! FeedLoaded || current.nextCursor == null || _loadingMore) {
      return;
    }

    _loadingMore = true;
    emit(
      FeedLoaded(
        current.videos,
        current.nextCursor,
        categories: current.categories,
        tags: current.tags,
        category: current.category,
        tag: current.tag,
        query: current.query,
        isLoadingMore: true,
      ),
    );
    try {
      final page = await _repo.list(
        before: current.nextCursor,
        category: _category,
        tag: _tag,
        searchQuery: _query,
      );
      emit(
        FeedLoaded(
          [...current.videos, ...page.items],
          page.nextCursor,
          categories: current.categories,
          tags: current.tags,
          category: _category,
          tag: _tag,
          query: _query,
        ),
      );
    } catch (e) {
      emit(FeedError(e.toString()));
    } finally {
      _loadingMore = false;
    }
  }

  Future<void> setFilters({
    String? category,
    String? tag,
    String? query,
  }) async {
    _category = category;
    _tag = tag;
    _query = query?.trim() ?? _query;
    await load();
  }

  bool isLiked(String videoId) => _likedVideoIds.contains(videoId);

  Future<void> toggleLike(Video video) async {
    final current = state;
    if (current is! FeedLoaded) return;
    final liked = isLiked(video.id);
    try {
      final count = liked
          ? await _repo.unlike(video.id)
          : await _repo.like(video.id);
      if (liked) {
        _likedVideoIds.remove(video.id);
      } else {
        _likedVideoIds.add(video.id);
      }
      emit(
        FeedLoaded(
          current.videos
              .map(
                (item) => item.id == video.id
                    ? item.copyWith(likesCount: count)
                    : item,
              )
              .toList(),
          current.nextCursor,
          categories: current.categories,
          tags: current.tags,
          category: current.category,
          tag: current.tag,
          query: current.query,
        ),
      );
    } catch (_) {}
  }
}
