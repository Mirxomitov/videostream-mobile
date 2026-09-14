import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/auth_bloc.dart';
import 'features/feed/presentation/feed_bloc.dart';
import 'features/upload/presentation/upload_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await setupDependencies();
  runApp(const VideoStreamApp());
}

class VideoStreamApp extends StatelessWidget {
  const VideoStreamApp({super.key});
  static final router = AppRouter();
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<AuthCubit>()),
      BlocProvider(create: (_) => sl<FeedCubit>()),
      BlocProvider(create: (_) => sl<UploadCubit>()),
    ],
    child: MaterialApp.router(
      title: 'VideoStream',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routerConfig: router.config(),
    ),
  );
}
