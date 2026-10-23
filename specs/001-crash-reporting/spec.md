# 001 — Crash reporting and a release build artifact

| Field | Value |
|---|---|
| Status | implemented on `main` (2026-10-23) |
| Commits | `8c499e8` (CI), `9198c4f` (Sentry), `b8a5cf7` + `0cd7a9a` (docs) |
| Owner / AI maker | bookchaowalit / Claude Code (b-tier-b) |
| Related | [PRODUCT.md](../../PRODUCT.md), [PRIVACY.md](../../PRIVACY.md), [KPI plan](../../docs/measurement/KPI-PLAN.md) |

## Problem

The app had no way to learn that it crashed, and CI produced only a debug APK, so there was no release-mode
build to inspect. Crash reporting must keep the app's privacy promise: goal titles and notes are personal and none
of that may leave the device, and the privacy policy and Play Data safety draft must stay true.

## Outcome

1. A build made with `--dart-define=SENTRY_DSN=...` sends **errors only** to Sentry (org `personal-yu0`, project
   `productivity-goal-tracker-mobile`), with user, request, breadcrumbs, extra data, device name and exception
   messages removed. Without a DSN (every local, test and debug build) Sentry is not initialised at all.
2. The Settings "Private by default" panel tells the truth in both cases; `PRIVACY.md` describes crash reports and
   `STORE-LISTING.md` says the Data safety form must declare crash logs before a DSN build is distributed.
3. On every push to `main`, CI builds a debug APK and a release app bundle with the DSN from the `SENTRY_DSN`
   secret, and uploads both as the workflow artifact `goal-tracker-android-<sha>` with SHA-256 in the summary. The
   release bundle is **unsigned** (no upload keystore exists); a CI-only Gradle property allows that, and a release
   build without it still fails closed (checked in CI).
4. The shared security workflow (gitleaks, Semgrep, OSV-Scanner on `pubspec.lock`, Trivy) runs on every push and PR.

## Acceptance criteria and tests (`test/crash_reporting_test.dart` unless noted)

| # | Criterion | Test |
|---|---|---|
| A1 | No DSN (empty or blank) means crash reporting is off | "crashReportingEnabled is off without a DSN" |
| A2 | A DSN turns it on | "is on with a DSN" |
| A3 | Options: no default PII, no tracing, no screenshots or view hierarchy, scrub hooks set | "sends errors only, with no default PII and no tracing" |
| A4 | Every breadcrumb is dropped | "drops every breadcrumb before it is recorded" |
| A5 | User, request, breadcrumbs, extra and server name are stripped | "strips user, request, breadcrumbs, extra and server name" |
| A6 | Exception type kept, exception value (may quote stored goal text) dropped | "keeps the exception type but drops its value…" |
| A7 | Settings copy without DSN makes no crash-report claim | widget test "promises nothing leaves the device when reporting is off" |
| A8 | Settings copy with DSN discloses Sentry crash reports | widget test "discloses crash reports when they are on" |
| A9 | Unsigned release still fails without the CI flag | CI step "Verify Android release signing fails closed without credentials" |
| A10 | Release bundle + debug APK uploaded with SHA-256 | CI job "Android builds (main only)" |

## Red-first evidence (ADR-0004)

The tests were written before `lib/observability/crash_reporting.dart` existed. Running them on a copy of the
committed tree plus the new test (Flutter 3.44.9, 2026-10-23) failed to compile:

```text
test/crash_reporting_test.dart:4:8: Error: Error when reading 'lib/observability/crash_reporting.dart': No such file or directory
test/crash_reporting_test.dart:12:14: Error: Method not found: 'crashReportingEnabled'.
```

After the implementation: `flutter analyze` "No issues found", `flutter test` "+29: All tests passed!".

## UI sign-off

The change touches only the Settings privacy panel. Checked in Flutter web builds of this commit (with and without
a dummy DSN on `example.invalid`, so nothing was sent) at 375 (NavigationBar), 768 and 1440 px (NavigationRail),
Goals and Settings tabs:

- Without DSN: panel reads "Goals stay on this device. There is no account, advertising, analytics, or cloud sync."
- With DSN: the crash report sentence is added; it wraps cleanly in the card at 375 px, no clipping or overlap at
  768 or 1440 px. Goals screen unchanged.

Screenshots: `~/work/b-tier-b/shots/productivity-goal-tracker-mobile-sentry/` (owner machine). Signed off by Claude
Code (AI reviewer), 2026-10-23. Not yet run on an Android device or emulator; the Maestro smoke flow was not re-run.

## Out of scope

- Product analytics (D4 chose PostHog free tier; no key yet), reminders, export, store release, signing.
- Native (Kotlin/NDK) crash capture and ANR reporting: off so every event passes through the Dart scrubber.

## Deploy state

No live URL and nothing in a store. The deliverable is the CI artifact on `main`; the release bundle is unsigned
and cannot be installed or uploaded until an upload keystore exists (owner action).
