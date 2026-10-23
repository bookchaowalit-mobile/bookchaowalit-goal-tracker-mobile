# Goal Tracker Mobile

**Tier:** Mobile release candidate (not store-released)  
**Stack:** Flutter 3.44.9 + Dart, Material 3, `ChangeNotifier`, `shared_preferences`, `pubspec.lock`  
**CI:** `.github/workflows/build.yml`: format, analyze, test, the release-signing negative check, the shared
security scan, and on `main` a debug APK plus an unsigned release app bundle uploaded as a workflow artifact

## What it is and who it is for

An offline Android app for someone who wants to keep a short list of personal, health, learning or work goals,
move their progress from 0 to 100 %, and see them together in one review. It is a portfolio piece showing a
local-first Flutter app with rollback on failed writes, phone and tablet layouts, and a store-ready release
process, not a coaching or habit system.

## What works today

- Create, edit, complete and delete goals with title, area, optional target date and next-step note
  (`lib/controllers/goal_controller.dart`); progress 0–100 %, "Summit reached" at 100 %.
- Due labels ("Due today", "Due tomorrow", overdue) from pure, tested logic (`lib/logic/due_dates.dart`).
- Local persistence with `shared_preferences`; a failed write rolls the list back and shows an error; unreadable
  saved goals are skipped and counted instead of crashing the app. **Clear all goals** in Settings.
- Phone `NavigationBar` and tablet `NavigationRail`; system light/dark theme; text-scale widget tests.
- Crash reporting with Sentry, **errors only**, only in builds made with a `SENTRY_DSN` (today only the CI release
  bundle). User, request, breadcrumbs, extra data, device name and exception messages are removed before sending;
  no tracing, sessions, screenshots or native crash capture. When it is on, the Settings privacy panel ("Private by default") says so.
  Every other build makes no network calls.
- 29 unit and widget tests (`test/`), including the Sentry scrubbing and the privacy copy; a Maestro smoke flow
  (`.maestro/smoke.yaml`) that is run by hand, not in CI.

## What does not work yet

- No reminders or notifications, no sub-tasks or milestones, no history chart.
- No account, backend, sync or analytics; no export of saved data.
- Not in any store. The CI release bundle is **unsigned** (no upload keystore exists yet) and cannot be installed or
  uploaded; the installable CI build is the debug APK. The privacy policy has no public URL yet (release blocker in
  `STORE-LISTING.md`).
- Not run on a device or emulator for the Sentry change; the Maestro flow was last run by hand before it.

## Where it runs

- No live URL. The deliverable is the CI workflow artifact `goal-tracker-android-<sha>` on `main`
  (debug APK + unsigned release AAB, SHA-256 in the run summary).
- The web version is a separate repository, `bookchaowalit-website/productivity-goal-tracker-web`; its portfolio
  card is reviewed in `portfolio-site-web/docs/audits/CARD-CLAIMS-REVIEW-2026-10.md`. This app has no card of its own.

## Release and privacy documents

[RELEASE.md](RELEASE.md), [STORE-LISTING.md](STORE-LISTING.md), [PRIVACY.md](PRIVACY.md), [docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Measurement and specs

- KPI plan: [docs/measurement/KPI-PLAN.md](docs/measurement/KPI-PLAN.md) (draft; Sentry is the only live signal).
- Specs: [specs/](specs/).
