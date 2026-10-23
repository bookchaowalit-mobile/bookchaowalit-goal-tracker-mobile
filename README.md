# Goal Tracker — Mobile

An offline-first Flutter app for creating goals, tracking progress, and
reviewing completed goals. Goal data is stored only in local app preferences;
the app has no account, advertising, analytics, or app-managed cloud sync.

Crash reporting (Sentry, errors only, scrubbed of user data and exception
messages) is compiled in only when a build passes
`--dart-define=SENTRY_DSN=...`, which only the CI release bundle does. Every
other build makes no network calls. See `lib/observability/crash_reporting.dart`
and [PRIVACY.md](./PRIVACY.md).

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s portfolio projects.

## Stack

- Flutter 3.44.9 and Dart 3.12
- Material 3 with system light/dark appearance
- `ChangeNotifier` application state
- `shared_preferences` local persistence
- Phone `NavigationBar` and tablet `NavigationRail`

## Develop and verify

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

The critical Android journey is also covered by Maestro:

```bash
maestro test .maestro/smoke.yaml
```

## Android release

The package ID is `com.bookchaowalit.goaltracker`, with a minimum Android API
level of 24 and target API level of 36. Release builds fail closed unless an
upload keystore and ignored `android/key.properties` are configured; debug
signing is never used for a release artifact. CI alone sets the Gradle
property `allowUnsignedRelease=true` to build an **unsigned** release bundle,
uploaded with the debug APK as the workflow artifact `goal-tracker-android-<sha>`
(SHA-256 in the run summary); it cannot be installed or uploaded to Play.

See [RELEASE.md](./RELEASE.md), [STORE-LISTING.md](./STORE-LISTING.md), and
[PRIVACY.md](./PRIVACY.md) before creating or updating the Play Console entry.

## License

MIT
