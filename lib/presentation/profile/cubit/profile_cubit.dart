import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/profile_repository.dart';

class ProfileState extends Equatable {
  const ProfileState({this.data, this.loading = false, this.error});
  final ProfileData? data;
  final bool loading;
  final String? error;
  @override
  List<Object?> get props => [data, loading, error];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());
  final ProfileRepository _repository;

  Future<void> load() async {
    emit(ProfileState(data: state.data, loading: true));
    try {
      emit(ProfileState(data: await _repository.me()));
    } catch (error) {
      emit(ProfileState(data: state.data, error: error.toString()));
    }
  }

  Future<void> updateName(String fullName) async {
    await _repository.updateName(fullName);
    await load();
  }
}
