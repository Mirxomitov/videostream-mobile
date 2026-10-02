// End-to-end click-through against the LIVE backend (stream.medic24.tj).
// Drives the real app: OTP login -> feed loads -> open a video -> HLS player
// initializes. Run with:
//   flutter test integration_test/app_test.dart -d macos \
//     --dart-define=API_BASE_URL=https://stream.medic24.tj
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:integration_test/integration_test.dart';

import 'package:videostream_mobile/app.dart';
import 'package:videostream_mobile/core/cache/token_storage.dart';
import 'package:videostream_mobile/core/di/service_locator.dart';

/// Pumps frames until [finder] matches or [timeout] elapses. Unlike
/// pumpAndSettle, this tolerates ongoing async work (network, video) between
/// frames, which is exactly what a live-backend test needs.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 40),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 300));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OTP login -> feed loads -> video plays (live backend)', (
    tester,
  ) async {
    await GetStorage.init();
    await setupDependencies();
    await sl<TokenStorage>().clear(); // always start logged out

    await tester.pumpWidget(const VideoStreamApp());

    // --- Phone screen --- (avoid pumpAndSettle; it can hang forever)
    await pumpUntil(tester, find.text('Send code'));
    await tester.enterText(find.byType(TextField).first, '+992900555001');
    await tester.tap(find.text('Send code'));

    // --- OTP screen (requestOtp succeeded and pushed OtpRoute) ---
    await pumpUntil(tester, find.text('Continue'));
    await tester.enterText(find.byType(TextField).last, '123123');
    await tester.tap(find.text('Continue'));

    // --- Feed screen (login succeeded -> replace with FeedRoute) ---
    await pumpUntil(tester, find.byIcon(Icons.upload_file));
    expect(find.text('VideoStream'), findsWidgets);

    // Feed fetched from the live API; we deployed a ready video, so expect one.
    await pumpUntil(tester, find.byType(ListTile));
    expect(
      find.byType(ListTile),
      findsWidgets,
      reason: 'live backend should return at least one ready video',
    );

    // --- Open the player and confirm the HLS stream initializes ---
    await tester.tap(find.byType(ListTile).first);
    await pumpUntil(
      tester,
      find.byType(Chewie),
      timeout: const Duration(seconds: 40),
    );
    expect(
      find.byType(Chewie),
      findsOneWidget,
      reason: 'HLS stream from cdn.medic24.tj should initialize',
    );
    expect(find.text('Could not load video.'), findsNothing);
  });
}
