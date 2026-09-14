import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/upload_repository.dart';

sealed class UploadState extends Equatable {
  const UploadState();
  @override
  List<Object?> get props => [];
}

class UploadIdle extends UploadState {}

class UploadPicking extends UploadState {}

class UploadReady extends UploadState {
  const UploadReady(this.file);
  final File file;
  @override
  List<Object?> get props => [file.path];
}

class Uploading extends UploadState {
  const Uploading(this.progress);
  final double progress;
  @override
  List<Object?> get props => [progress];
}

class UploadDone extends UploadState {}

class UploadError extends UploadState {
  const UploadError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class UploadCubit extends Cubit<UploadState> {
  UploadCubit(this._repo) : super(UploadIdle());
  final UploadRepository _repo;
  Future<void> pick() async {
    emit(UploadPicking());
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result?.files.single.path != null) {
      emit(UploadReady(File(result!.files.single.path!)));
    } else {
      emit(UploadIdle());
    }
  }

  Future<void> upload(
    String title,
    String? description, {
    String? category,
    List<String> tags = const [],
  }) async {
    final current = state;
    if (current is! UploadReady) return;
    try {
      final response = await _repo.create(title, description);
      await _repo.putFile(
        response.uploadUrl,
        current.file,
        (sent, total) => emit(Uploading(total <= 0 ? 0 : sent / total)),
      );
      await _repo.updateMetadata(response.videoId, category, tags);
      await _repo.complete(response.videoId);
      emit(UploadDone());
    } catch (e) {
      emit(UploadError(e.toString()));
    }
  }
}
