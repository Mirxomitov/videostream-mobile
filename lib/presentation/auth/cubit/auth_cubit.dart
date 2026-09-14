import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/auth_repository.dart';
import '../../../core/cache/token_storage.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthIdle extends AuthState {}

class AuthLoading extends AuthState {}

class AuthCodeSent extends AuthState {}

class AuthAuthenticated extends AuthState {}

class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo, this._storage) : super(AuthIdle());
  final AuthRepository _repo;
  final TokenStorage _storage;
  Future<void> requestOtp(String phone) async {
    emit(AuthLoading());
    try {
      await _repo.requestOtp(phone);
      emit(AuthCodeSent());
    } catch (e) {
      emit(
        AuthFailure(
          e is Exception && e.toString().contains('Failure')
              ? e.toString().replaceFirst('Instance of ', '')
              : 'Could not send code.',
        ),
      );
    }
  }

  Future<void> login(String phone, String code) async {
    emit(AuthLoading());
    try {
      final response = await _repo.login(phone, code);
      await _storage.save(response.accessToken);
      emit(AuthAuthenticated());
    } catch (_) {
      emit(const AuthFailure('Invalid code or server error.'));
    }
  }
}
