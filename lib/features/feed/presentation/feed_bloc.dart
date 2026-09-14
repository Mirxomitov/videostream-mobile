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
  const FeedLoaded(this.videos, this.nextCursor, {this.isLoadingMore = false});
  final List<Video> videos;
  final String? nextCursor;
  final bool isLoadingMore;
  @override
  List<Object?> get props => [videos, nextCursor, isLoadingMore];
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

  Future<void> load() async {
    _loadingMore = false;
    emit(FeedLoading());
    try {
      final page = await _repo.list();
      emit(FeedLoaded(page.items, page.nextCursor));
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
    emit(FeedLoaded(current.videos, current.nextCursor, isLoadingMore: true));
    try {
      final page = await _repo.list(before: current.nextCursor);
      emit(FeedLoaded([...current.videos, ...page.items], page.nextCursor));
    } catch (e) {
      emit(FeedError(e.toString()));
    } finally {
      _loadingMore = false;
    }
  }
}
