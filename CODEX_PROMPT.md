# Codex task: build the Flutter client for a video-streaming platform

You are implementing the **mobile client** for an existing NestJS backend. The Flutter project
already exists at the repo root (`videostream-mobile`, package name `videostream_mobile`,
Flutter 3.44, Dart 3). Build the app described below. Match the stack and architecture exactly —
do not swap libraries for "better" ones.

## Goal (vertical slice)

A user can: **log in with phone + OTP → see a feed of ready videos → tap one and watch it (HLS,
adaptive) → upload a new video from the device.** Ship that whole loop.

## Tech stack (use exactly these)

| Concern | Package |
|---|---|
| State management | `flutter_bloc`, `equatable` |
| HTTP | `dio`, `pretty_dio_logger` |
| DI / service locator | `get_it` |
| Navigation | `auto_route` |
| Local storage (token) | `get_storage` |
| Images | `cached_network_image`, `flutter_svg` |
| Video playback (HLS) | `video_player` + `chewie` (prefer these; `better_player` is unmaintained on Flutter 3.44) |
| File/media picker | `image_picker` and/or `file_picker` |

Add them with `flutter pub add`. Generate auto_route code with build_runner.

## Architecture (feature-first, mirrors the team's `wisdom_mobile` conventions)

```
lib/
  core/
    di/            # get_it setup (registerLazySingleton for dio, repos, blocs as factories)
    network/       # dio client + auth interceptor + error mapping
    router/        # auto_route AppRouter
    storage/       # get_storage wrapper for the JWT
    constants/     # base url, keys
    theme/
  features/
    auth/
      data/        # AuthRepository, AuthApi (dio calls)
      domain/      # models (LoginResponse, User)
      presentation/# AuthBloc/Cubit, login screen
    feed/
      data/ domain/ presentation/   # VideoRepository, Video model, FeedBloc, feed screen
    player/
      presentation/# player screen (video_player + chewie)
    upload/
      data/ presentation/  # upload flow + UploadBloc, upload screen with progress
  main.dart
```

Use BLoC/Cubit for every screen's state (loading / loaded / error). Inject repositories via get_it
(constructor injection into blocs). Keep API/DTO models separate from widgets.

## Backend API contract (this is exact — do not invent endpoints)

**Base URL (dev):**
- Android emulator: `http://10.0.2.2:3000`
- iOS simulator: `http://localhost:3000`
- Physical device: `http://<your-mac-LAN-ip>:3000`
Put this in `core/constants` and select by platform.

**Auth (public, no token):**
- `POST /auth/otp` body `{ "phone": "+998..." }` → `{ "ok": true }` (request an OTP)
- `POST /auth/login` body `{ "phone": "+998...", "code": "123123" }` → `{ "access_token": "<JWT>" }`
  - **Dev shortcut:** the OTP is ALWAYS `123123`. Still show a real 2-screen flow (enter phone → enter code).

**Everything else requires** header `Authorization: Bearer <access_token>`:
- `GET /users/me` → the current user document `{ "_id", "phone", "created_at", ... }`
- `GET /videos` → array of **ready** videos only. Video shape:
  ```json
  {
    "_id": "6aa7...", "title": "string", "description": "string|null",
    "status": "ready", "owner_id": "6a62...",
    "hls_url": "string|null", "thumbnail_url": "string|null", "duration": 12.3,
    "mux_playback_id": "string|null",
    "created_at": "ISO", "updated_at": "ISO"
  }
  ```
- `POST /videos/upload` body `{ "title": "string", "description": "string?" }`
  → `{ "video_id": "6aa7...", "upload_url": "https://...mux.com/upload/...?token=..." }`

**Playback URL:** build HLS URL from the video as
`https://stream.mux.com/<mux_playback_id>.m3u8`.
(If `hls_url` is populated, prefer it; otherwise derive from `mux_playback_id`.)

## The upload flow (important — two steps)

1. Call `POST /videos/upload` with the title → get `{ video_id, upload_url }`.
2. **PUT the raw file bytes directly to `upload_url`** (this goes to Mux, NOT your backend):
   ```dart
   await dio.put(uploadUrl, data: fileStream, options: Options(
     headers: {'Content-Type': 'video/mp4'},   // match the picked file's type
     contentType: 'video/mp4',
   ));
   ```
   Use the file length for progress; surface an upload progress bar via `onSendProgress`.
3. After the PUT succeeds the video is transcoding on Mux (status stays `uploading` server-side).
   For now, show an "uploaded, processing…" state and let the user pull-to-refresh the feed; the
   video appears in `GET /videos` once the backend marks it `ready` (a webhook, built separately).
   Do **not** block the UI waiting for ready.

## Networking details

- One `Dio` instance in `core/network`, base URL from constants.
- Add `pretty_dio_logger` in debug.
- **Auth interceptor:** read the JWT from `get_storage` and attach `Authorization: Bearer` on every
  request except `/auth/*`. On `401`, clear the token and route back to login.
- Map Dio errors to a small `Failure` type; blocs emit error states with a user-facing message.

## Screens

1. **Phone screen** — input phone, `POST /auth/otp`, navigate to OTP screen.
2. **OTP screen** — input code, `POST /auth/login`, store `access_token` in get_storage, go to feed.
   (Hint on screen in debug: code is `123123`.)
3. **Feed screen** — `GET /videos`, list with `cached_network_image` thumbnails (use
   `thumbnail_url`, or a placeholder), title, pull-to-refresh. Tap → player.
4. **Player screen** — play the HLS URL with `video_player` + `chewie`, adaptive, with controls.
5. **Upload screen** — pick a video (`image_picker`/`file_picker`), enter title, run the 2-step
   upload with a progress bar, then return to feed with the "processing" note.
6. **Auth gate** — on launch, if a token exists go to feed, else phone screen (auto_route guard).

## Definition of done

- `flutter analyze` clean; app builds and runs on an emulator.
- Full loop works against the running backend: log in (phone → `123123`) → feed loads → play a
  ready video → upload a new file and see the progress bar complete.
- Token persists across app restarts; 401 kicks back to login.
- Code is feature-organized as above, BLoC/Cubit per screen, repositories injected via get_it.

## Notes / gotchas

- Android: add `INTERNET` permission (default) and allow cleartext for `10.0.2.2` in debug
  (`android:usesCleartextTraffic="true"` or a network-security-config) since dev backend is HTTP.
- iOS: allow arbitrary loads for localhost in debug (`NSAppTransportSecurity`) if needed.
- Don't hardcode the token; always read from storage.
- Keep the backend's snake_case JSON in your model `fromJson` (`created_at`, `mux_playback_id`, etc.).
