## Purpose

This file gives concise, repository-specific guidance for AI coding agents to be immediately productive in this Flutter app.

**Keep guidance factual and discoverable**: reference only files and patterns present in the repo (examples below).

## Big Picture Architecture

- **Flutter app** with conventional platform directories (`android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`).
- **Layers:**
  - `lib/models/` — data shapes (e.g., `user_model.dart`, `post_model.dart`).
  - `lib/services/` — backend wrappers and API/Firebase interactions (e.g., `auth_service.dart`, `post_service.dart`).
  - `lib/providers/` — state management and glue to services (ChangeNotifier providers like `auth_provider.dart`).
  - `lib/screens/` and `lib/widgets/` — UI screens and reusable widgets (e.g., `screens/home_screen.dart`).

Design assumption: services implement platform-agnostic logic and are consumed by providers which expose state to UI. Keep that separation.

## Key Files & Patterns (look here first)
- `lib/main.dart` — app entrypoint and provider setup.
- `pubspec.yaml` — dependencies, assets. Update carefully when adding packages.
- `analysis_options.yaml` — static analysis rules; follow project linting.
- `lib/services/*_service.dart` — prefer adding new remote logic here rather than inside providers.
- `lib/providers/*_provider.dart` — providers extend `ChangeNotifier` and expose public methods used by UI.
- `lib/models/*.dart` — immutable-like plain data objects used across app.
- `assets/` — images and animations; reference paths in `pubspec.yaml`.

## Build / Run / Test (commands)
- Fetch deps: `flutter pub get`
- Run app (default device): `flutter run`
- Run tests: `flutter test`
- Format code: `dart format .` or `flutter format .`
- Analyze: `flutter analyze`

Note: the workspace already runs `flutter pub get` in CI/local flows. Use the above commands in the repo root.

## Project-specific conventions
- State: use `providers` (ChangeNotifier) for UI state and side-effects. Do not call `BuildContext`-dependent methods from service classes.
- Services: put networking or Firebase bindings in `lib/services/*_service.dart`. Keep methods small, return models, and throw meaningful exceptions for callers to handle.
- Providers should transform service outputs into simple UI state (loading/error/success) and notify listeners.
- UI: screens in `lib/screens/` call providers via `Provider.of`/`Consumer`. Add new reusable UI pieces in `lib/widgets/`.
- Tests: add unit tests under `test/` mirroring `lib/` layout (e.g., `test/services/`, `test/providers/`).

## Integration points and external dependencies
- Firebase: `firebase.json` and platform folders indicate Firebase usage. Check `lib/services/notification_service.dart` and auth/chat services for concrete Firebase APIs.
- Native platform files: iOS/Android configurations (e.g., `ios/Runner/Info.plist`, `android/app/`) may contain required keys — avoid breaking them.

## Editing guidance (do's and don'ts)
- Do: keep services platform-agnostic and testable; add unit tests for service logic.
- Do: run `dart format .` and `flutter analyze` before opening PRs.
- Don't: commit local machine secrets or `local.properties`.
- Don't: move public APIs across layers without updating all callers (providers → screens → widgets).

## Concrete examples to follow
- To add a new backend call:
  1. Add `lib/services/foo_service.dart` with methods returning model(s) from `lib/models/`.
  2. Add `lib/providers/foo_provider.dart` to wrap service calls and expose loading/error state.
  3. Use provider in `lib/screens/` or `lib/widgets/` via `Provider`.

- To modify app-wide state (e.g., current user): update `lib/providers/user_data_provider.dart` rather than passing state through constructors.

## Where to look for examples in this repo
- Authentication flow: `lib/services/auth_service.dart` + `lib/providers/auth_provider.dart` + `lib/screens/auth_screen.dart`.
- Posts / feed: `lib/services/post_service.dart` + `lib/providers/posts_provider.dart` + `lib/screens/feed/`.
- Bible features: `lib/services/bible_service.dart`, `lib/screens/bible_*` and `lib/models/bible_*`.

## If you need more context
- Read `README_ES.MD` and `README_EN.MD` for product-level context.
- For project rules, see `.github/instructions/instruction.instructions.md` (Spanish short rules).

## Final notes for agents
- Be conservative: when changing service or provider APIs, update all callers and add tests.
- Keep changes small and focused; document why code was added/changed in PR descriptions.

Please review this file and tell me any unclear spots or additional patterns you want included.
