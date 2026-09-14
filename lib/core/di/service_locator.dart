import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/auth_bloc.dart';
import '../../features/feed/data/video_repository.dart';
import '../../features/feed/presentation/feed_bloc.dart';
import '../../features/upload/data/upload_repository.dart';
import '../../features/upload/presentation/upload_bloc.dart';

final sl = GetIt.instance;
Future<void> setupDependencies() async {
  final box = GetStorage();
  final storage = TokenStorage(box);
  final client = ApiClient(storage);
  sl.registerSingleton<TokenStorage>(storage);
  sl.registerSingleton<Dio>(client.dio);
  sl.registerLazySingleton(() => AuthRepository(sl()));
  sl.registerLazySingleton(() => VideoRepository(sl()));
  sl.registerLazySingleton(() => UploadRepository(sl()));
  sl.registerFactory(() => AuthCubit(sl(), sl()));
  sl.registerFactory(() => FeedCubit(sl()));
  sl.registerFactory(() => UploadCubit(sl()));
}
