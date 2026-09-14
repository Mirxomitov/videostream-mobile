import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/comment_repository.dart';
import '../domain/comment.dart';

class CommentState extends Equatable {
  const CommentState({
    this.comments = const [],
    this.loading = false,
    this.error,
  });
  final List<VideoComment> comments;
  final bool loading;
  final String? error;
  @override
  List<Object?> get props => [comments, loading, error];
}

class CommentCubit extends Cubit<CommentState> {
  CommentCubit(this._repository) : super(const CommentState());
  final CommentRepository _repository;

  Future<void> load(String videoId) async {
    emit(CommentState(comments: state.comments, loading: true));
    try {
      emit(CommentState(comments: await _repository.list(videoId)));
    } catch (error) {
      emit(CommentState(comments: state.comments, error: error.toString()));
    }
  }

  Future<void> post(String videoId, String text) async {
    if (text.trim().isEmpty) return;
    try {
      final comment = await _repository.create(videoId, text.trim());
      emit(CommentState(comments: [comment, ...state.comments]));
    } catch (error) {
      emit(CommentState(comments: state.comments, error: error.toString()));
    }
  }
}
