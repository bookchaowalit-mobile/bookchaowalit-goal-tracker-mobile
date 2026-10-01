# Upgrade Plan — Goal Tracker Mobile

## Current state

Score: 8.5/10 — real offline-first app with persistence, rollback on failed
writes, tablet layout, text-scale tests, fail-closed CI and a release-signing
gate; remaining gaps are store-readiness and a few UX polish items.

## Backlog

### P0
- None known. Keep the release-signing gate in CI green.

### P1
- Offer an export of the raw saved payload before skipped (unreadable) goals
  are dropped by the next save (the count is now surfaced).
- Clock injection for the home screen so "Due today"/"Due tomorrow" can be
  widget-tested deterministically (the pure logic is unit-tested).
- Add a Maestro run to CI (or document why it stays manual) so
  `.maestro/smoke.yaml` cannot drift from the UI.
- Bump the CI Flutter pin in step with `pubspec.lock` (currently 3.44.9).

### P2
- Localisation (Thai/English) for UI strings.
- Goal reminders via local notifications (needs a privacy review first).

## Done in this pass (pass 3)

- Bug fix: due dates were shown as `Jan 5` with no year although the picker
  allows dates up to ten years ahead, so a goal due in 2029 looked like it
  was due this January. New `lib/logic/due_dates.dart` adds the year outside
  the current year.
- Overdue unfinished goals are now labelled `Overdue · <date>` in the error
  colour (with a distinct icon); today/tomorrow read `Due today`/`Due
  tomorrow`. Day maths uses UTC calendar dates (no DST off-by-one).
- P1 done: the load no longer drops malformed saved goals silently. The store
  reports how many it skipped (`ReportsSkippedRecords`), the controller exposes
  `skippedCount`, and home shows a dismissible live-region notice.
- Edge-case tests: due-date formatting/boundaries (year, leap day, UTC vs
  local, time of day), `Goal.fromJson` with fractional/out-of-range/missing
  values and unicode, `copyWith` clamping, average rounding, skipped counts.
  Widget tests: overdue and far-future labels, skipped-goals notice +
  dismiss, a11y guidelines (tap target, labels, contrast) on home.

## Done in an earlier pass

- `SharedPreferencesGoalStore.load` skips individual malformed entries (for
  example a numeric `id`) instead of failing the whole load and hiding every
  goal; added tests for that and for a non-list payload.
- CI now also checks `dart format` before analyze/test.
