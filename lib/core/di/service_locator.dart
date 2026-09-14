import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import '../api/api_client.dart';
import '../cache/token_storage.dart';
import '../../presentation/auth/data/auth_repository.dart';
import '../../presentation/auth/cubit/auth_cubit.dart';
import '../../presentation/home/data/video_repository.dart';
import '../../presentation/home/cubit/feed_cubit.dart';
import '../../presentation/upload/data/upload_repository.dart';
import '../../presentation/upload/cubit/upload_cubit.dart';

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
