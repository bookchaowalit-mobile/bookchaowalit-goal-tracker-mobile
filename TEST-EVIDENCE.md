# Android Release Evidence

Current verification: 15 October 2026 (Asia/Bangkok)

Historical Android/device evidence below was recorded on 31 August 2026.

## Candidate identity

- App: Goal Tracker
- Package: `com.bookchaowalit.goaltracker`
- Version: `1.0.0+1`
- Minimum SDK: 24
- Target/compile SDK: 36
- Tested source commit: `30b80ffb581307459d473d5b819eb3e87d87af80`
- Candidate implementation landed in `fdec48907007f33d85d9ecbc1fb7544385065b45`
  and is included in the tested source commit.
- Source state at verification: clean; no candidate code is waiting to be committed.

The evidence update is a documentation-only descendant of the tested source
commit. A commit cannot contain its own final hash; the explicit source pin
above identifies the verified code, and `git log -1 -- TEST-EVIDENCE.md` identifies
the later evidence commit. No APK or device claim is attached to that later
commit without a fresh build.

## Current local verification (BOO-211)

Flutter 3.44.9 / Dart 3.12.2, using the CI-pinned SDK version:

| Check | Result |
|---|---|
| `flutter pub get` | Passed with committed dependency versions unchanged |
| `dart format --output=none --set-exit-if-changed lib test` | Passed, 13 files, 0 changes |
| `flutter analyze --no-pub` | Passed, no issues found |
| `flutter test --no-pub` | Passed, 21 tests |
| `flutter build apk --debug --no-pub` | Unavailable: Android SDK is not installed |
| Maestro / device | Not rerun: Android SDK, emulator and Maestro unavailable |

The unit/widget suite now covers additional malformed storage, overdue date,
skipped-entry and accessibility regressions beyond the original seven tests.
The historical APK hash, screenshots and Maestro results below predate this
source commit and must not be used as current release evidence. A main CI
run and new device smoke evidence remain separate gates. Production is not
released.

## Historical automated verification (31 August 2026)

| Check | Result | Evidence |
|---|---|---|
| `flutter analyze` | Passed | No issues found |
| `flutter test` | Passed | 7 tests: model/sorting/completion, storage rollback, overlapping load/write protection, phone CRUD UI, tablet navigation, 130% text scale, and a past target date |
| `flutter build apk --debug` | Passed | Debug APK created successfully |
| Solo Empire `mobile:check` | Passed | Analyze, unit test, and Android debug build all passed |
| Release manifest merge | Passed | `app:processReleaseMainManifest` completed |
| Release signing guard | Passed as a negative test | `flutter build appbundle --release` stopped because upload signing is not configured |
| Maestro Android journey | Passed | Install, create, persist after restart, complete, review, edit, delete |
| Crash-log check | Passed | No crash output in the final Maestro run |

Final debug artifact:

```text
build/app/outputs/flutter-apk/app-debug.apk
SHA-256 e0b7b1f9aba4ce48debd24e735061a1b66e179c9fe3ebeab2007117e23e60730
```

This APK is debug-signed and is not eligible for Google Play upload.

## Release manifest inspection

The merged release manifest reports:

- `minSdkVersion="24"`
- `targetSdkVersion="36"`
- `android:allowBackup="false"`
- `android:fullBackupContent="false"`
- no `android.permission.INTERNET`
- no sensitive runtime permission

The generated app-specific dynamic receiver permission is internal Android
plumbing and does not grant access to user data.

## Native Android flow

Final flow: `.maestro/smoke.yaml`

1. Clear app state and verify the local-first empty state.
2. Create **Ship first Android app**.
3. Verify 0% progress, mark complete, and verify success feedback.
4. Stop and relaunch the app; verify the goal persisted.
5. Open Trail review and verify the completed goal.
6. Open the editor, request deletion, confirm, and verify the empty state.

The flow ran on `solo_empire_api_35`; install, Maestro, and crash-log checks all
returned `passed`.

## Visual and accessibility evidence

Manually inspected native emulator captures cover:

- 1080×1920 phone light mode
- 1080×1920 phone dark mode
- 1600×2560 expanded layout with `NavigationRail` and the latest responsive
  half-width goal grid
- Android font scale 130%, covered by a retained widget test

No Flutter overflow indicator or clipped primary action was observed. The
critical goal journey uses visible labels plus semantics for progress and
icon-only actions. A physical-device/TalkBack pass is still required from the
Play-delivered internal build.

## Store asset validation

- Icon: 512×512, 32-bit PNG with alpha, under 1 MB
- Feature graphic: 1024×500, 24-bit PNG without alpha
- Five phone screenshots: 1080×1920, 24-bit PNG without alpha
- One expanded-layout QA screenshot: 1600×2560, 24-bit PNG without alpha
- Asset provenance scan: 9 rasters, 0 missing prompt/capture metadata

## Open release gates

- [ ] Connect an authenticated Play Console browser and verify the developer
      account/organization profile
- [ ] Publish `PRIVACY.md` at a stable public URL
- [ ] Confirm the permanent Play package ID before app creation
- [ ] Enroll in Play App Signing and configure an upload key in the approved
      secret manager
- [x] Commit the candidate implementation (included in the tested source pin)
- [ ] Push an authorized candidate and verify its main CI build/artifact
- [ ] Build and hash a signed release AAB
- [ ] Upload to Internal testing and pass Play pre-launch/policy checks
- [ ] Test the Play-delivered build on a physical Android device with TalkBack
- [ ] Promote the tested artifact through a staged production rollout

Production status: **not released**.
