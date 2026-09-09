---
name: Goal Tracker Mobile
description: A private, offline-first Android goal tracker guided by calm alpine wayfinding.
colors:
  pine: "#174936"
  trail-orange: "#CA542D"
  alpine-sky: "#2C6F8F"
  snow: "#F7F5EF"
  night: "#101B17"
breakpoints:
  navigation-rail: "720dp"
  two-column-goals: "680dp content width"
rounded:
  field: "16dp"
  card: "20dp"
  progress-panel: "24dp"
  trail-hero: "28dp"
---

# Goal Tracker Design System

## Product intent

Goal Tracker is a focused Android tool for planning meaningful goals, recording
a next step or target date, tracking progress from 0–100%, and reviewing
completed goals. It is offline-first: there is no account, advertising,
analytics, app-managed cloud sync, or remote runtime content.

## Creative direction: Alpine Trail Wayfinding

Goals are destinations, active work is a trail, and completed goals are
summits. Mountain, route, contour, signpost, and flag cues make progress easier
to scan without turning the product into a game. The metaphor belongs on
progress and encouragement surfaces; settings, errors, and destructive actions
stay direct.

## Color and type

The light palette combines Snow surfaces with Pine actions, Trail Orange for
movement, and Alpine Sky for aggregate progress. Dark mode uses Night surfaces
with softened mint, orange, and blue roles. Derived colors must come from
`Theme.of(context).colorScheme`; text and icons on a Material role must use its
matching `on*` role. Trail Orange is a progress cue, not general decoration.

The app uses the Android Material 3 type system and platform-default Roboto.
Consume type through `Theme.of(context).textTheme`. Goal titles may ellipsize
inside list cards only because the full value is available in the editor.

## Layout and navigation

- Phone lists use 16dp horizontal margins; editor/review content uses 20dp.
- Use the 8/12/16/20/24/32 spacing rhythm and respect system/keyboard insets.
- Below 720dp, show only the 72dp `NavigationBar` and icon FAB.
- At 720dp and wider, show only the labeled `NavigationRail` and extended Add
  goal FAB.
- At 680dp content width, goal lists use two columns so common 800dp tablets do
  not stretch a single phone card across the page.
- Goals, Progress, and Settings retain their ordering, labels, icons, and
  selected state at every breakpoint.

Cards are flat, with tonal containers and outline-variant borders rather than
decorative shadows. Material elevation is reserved for floating actions,
dialogs, snackbars, and transient system surfaces.

## Core components

### Trail overview

The signature 28dp-radius panel combines contour lines, a route whose length
reflects aggregate progress, numeric progress, active/completed counts, and an
Offline badge. Color is never the only progress indicator.

### Goal cards

Each card opens the editor and exposes a separate flag control to mark a goal
complete. Cards show the title, numeric percentage, progress bar, category,
optional date, and chevron. Completion is communicated by flag state, 100%,
section placement, progress color, and title strike-through.

### Forms

Use Material fields, ChoiceChips, a native date picker, and a progress slider in
5% steps. Preserve visible validation, keyboard-safe scrolling, and a clear
primary submit action.

## Interaction and accessibility

- Keep interactive targets at least 48×48dp.
- Pair icon-only actions with tooltips and semantic labels.
- Expose progress as text and semantics, not only as color or a bar.
- Preserve native focus behavior and logical TalkBack traversal.
- Follow Android light/dark appearance and text scaling.
- Announce save success or failure with concise snackbars.
- Use standard Material state transitions; meaning must not depend on motion.

## Empty, loading, and error states

- First run: signpost, **No goals yet**, local-first explanation, and Add hint.
- Filtered empty: name the empty category and offer **Show all goals**.
- Review empty: explain how to create or complete a goal.
- Loading: neutral blocks shaped like the trail panel and goal cards.
- Load failure: warning, actionable message, and **Try again**.
- Write failure: roll back the optimistic change and show a failure snackbar.

Every state must stay scroll-safe at 130% Android font scaling.

## Destructive actions

Deletion is separated from Save/Create by a 56dp gap, divider, irreversible
warning, and error-colored outline action. Individual and bulk deletion both
require a confirmation dialog that states the exact scope, places the safe
action first, and places the destructive action last. Do not add swipe-to-delete.

## Assets and provenance

- Runtime icons use Flutter Material `Icons`.
- `_TrailMapPainter` renders contours and the route locally in code.
- `assets/app-icon-source.png` is the working generated icon source.
- `assets/store/icon-512.png` and
  `assets/store/feature-graphic-1024x500.png` are Play exports.
- `assets/store/screenshots/` contains native emulator captures; regenerate
  them after material UI changes rather than editing app state into an image.
- Every raster under `assets/` carries an `impeccable:prompt` PNG metadata entry
  recording its generation or capture provenance.

## Verification matrix

| Case | Pass criteria |
|---|---|
| Phone light | Core screens, chips, dialogs, snackbars, FAB, and navigation have no clipping or hidden actions. |
| Phone dark | No light-surface leakage; text, selected states, tracks, and error actions retain contrast. |
| 130% font | No overflow; pages scroll where needed; labels and 48dp targets remain usable. |
| 719/720dp | 719dp shows only the bar; 720dp shows only the labeled rail with the same selected destination. |
| Tablet | Rail, extended FAB, insets, and card columns remain aligned and usable. |
| Accessibility | Logical focus order, descriptive semantics, spoken progress, and non-color status cues. |
