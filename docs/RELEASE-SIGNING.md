# Release signing (Android upload key)

Created 2026-10-24 (session oa-remainder, owner instruction). The keystore and its passwords
exist **only** in Infisical; nothing is in Git.

| Item | Value |
|---|---|
| Application id | `com.bookchaowalit.goaltracker` |
| Keystore type / key | PKCS12, RSA 4096, alias `upload`, valid 9125 days (25 years) |
| Certificate SHA-256 | `50:FA:33:44:F7:E9:8C:D7:17:85:53:4F:2E:1E:E8:74:88:D4:5A:5E:8B:6F:C1:CD:0C:13:3C:21:01:7E:37:EB` |
| Infisical folder | `/android` |
| Keystore (base64) | `ANDROID_GOAL_TRACKER_UPLOAD_KEYSTORE_B64` |
| Store password | `ANDROID_GOAL_TRACKER_UPLOAD_STORE_PASSWORD` |
| Key password | `ANDROID_GOAL_TRACKER_UPLOAD_KEY_PASSWORD` (same value as the store password, as PKCS12 requires) |
| Alias | `ANDROID_GOAL_TRACKER_UPLOAD_KEY_ALIAS` (`upload`) |

This is the **upload** key. With Play App Signing, Google holds the app signing key; register
this certificate as the upload certificate when the app is created in Play Console (an owner
step: it needs the Play developer account). If the upload key is lost or leaks, ask Play
support to reset the upload key; do not reuse it for another app.

## Gradle

`android/app/build.gradle.kts` already reads `android/key.properties` and fails a release build without it.

## Build a signed bundle locally

Write the files outside the repository and never print the values:

```bash
source ~/.config/solo-empire/environment.sh
mkdir -p ~/.android-upload && chmod 700 ~/.android-upload
infisical run --projectId "$INFISICAL_PROJECT_ID" --env dev --path /android --silent -- bash -c '
  umask 077
  printf %s "$ANDROID_GOAL_TRACKER_UPLOAD_KEYSTORE_B64" | base64 -d > ~/.android-upload/goal_tracker.jks
  printf "storeFile=%s\nstorePassword=%s\nkeyPassword=%s\nkeyAlias=%s\n" \
    ~/.android-upload/goal_tracker.jks "$ANDROID_GOAL_TRACKER_UPLOAD_STORE_PASSWORD" \
    "$ANDROID_GOAL_TRACKER_UPLOAD_KEY_PASSWORD" "$ANDROID_GOAL_TRACKER_UPLOAD_KEY_ALIAS" > android/key.properties'
flutter build appbundle --release
```

`android/key.properties`, `*.jks` and `*.keystore` are git-ignored. CI still builds an unsigned
bundle: wiring these secrets into CI is a separate change.
