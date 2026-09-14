import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../presentation/auth/screens/auth_screens.dart';
import '../../presentation/home/screens/home_screen.dart';
import '../../presentation/home/domain/video.dart';
import '../../presentation/player/screens/player_page.dart';
import '../../presentation/upload/screens/upload_screen.dart';
import '../di/service_locator.dart';
import '../cache/token_storage.dart';
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
