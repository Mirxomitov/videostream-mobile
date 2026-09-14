import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'core/routes/app_router.dart';
import 'presentation/auth/cubit/auth_cubit.dart';
import 'presentation/home/cubit/feed_cubit.dart';
import 'presentation/upload/cubit/upload_cubit.dart';

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
