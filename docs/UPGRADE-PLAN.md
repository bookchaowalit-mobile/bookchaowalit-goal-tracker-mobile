# Upgrade Plan — Goal Tracker Mobile

## Current state

Score: 8/10 — real offline-first app with persistence, rollback on failed
writes, tablet layout, text-scale tests, fail-closed CI and a release-signing
gate; remaining gaps are store-readiness and a few UX polish items.

## Backlog

### P0
- None known. Keep the release-signing gate in CI green.

### P1
- Surface a count of skipped malformed goals after load (currently silently
  dropped) and offer an export of the raw payload before clearing.
- Add a Maestro run to CI (or document why it stays manual) so
  `.maestro/smoke.yaml` cannot drift from the UI.
- Bump the CI Flutter pin in step with `pubspec.lock` (currently 3.44.9).

### P2
- Localisation (Thai/English) for UI strings.
- Goal reminders via local notifications (needs a privacy review first).

## Done in this pass

- `SharedPreferencesGoalStore.load` skips individual malformed entries (for
  example a numeric `id`) instead of failing the whole load and hiding every
  goal; added tests for that and for a non-list payload.
- CI now also checks `dart format` before analyze/test.
