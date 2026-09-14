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
  const FeedLoaded(this.videos);
  final List<Video> videos;
  @override
  List<Object?> get props => [videos];
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
  Future<void> load() async {
    emit(FeedLoading());
    try {
      emit(FeedLoaded(await _repo.list()));
    } catch (e) {
      emit(FeedError(e.toString()));
    }
  }
}
