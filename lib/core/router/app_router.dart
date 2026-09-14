import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/auth_screens.dart';
import '../../features/feed/presentation/feed_page.dart';
import '../../features/feed/domain/video.dart';
import '../../features/player/presentation/player_page.dart';
import '../../features/upload/presentation/upload_page.dart';
import '../di/service_locator.dart';
import '../storage/token_storage.dart';
part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: PhoneRoute.page,
      path: '/',
      initial: sl<TokenStorage>().token == null,
    ),
    AutoRoute(page: OtpRoute.page),
    AutoRoute(
      page: FeedRoute.page,
      path: '/feed',
      initial: sl<TokenStorage>().token != null,
    ),
    AutoRoute(page: PlayerRoute.page),
    AutoRoute(page: UploadRoute.page),
  ];
}
