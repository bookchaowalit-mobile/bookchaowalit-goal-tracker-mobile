# Google Play Store Listing

## Listing copy

**App name**  
Goal Tracker

**Default language**  
English (United States)

**Short description**  
Plan meaningful goals and track progress privately, entirely on your device.

**Full description**

Choose a meaningful destination, take one clear step, and see how far you have
come. Goal Tracker is a focused, offline-first place to plan personal, health,
learning, and work goals without creating an account.

Create and organize goals, add a target date or next-step note, update progress,
and mark a summit reached when the goal is complete. The Trail review brings
your active and completed goals together in one simple progress view.

Your goals stay private. Goal Tracker has no advertising, analytics, account,
or app-managed cloud sync. Goal data is stored locally on your Android device,
and you can edit, delete, or clear it from the app at any time.

Highlights:

- Create, edit, complete, and delete goals
- Organize goals by Personal, Health, Learning, or Work
- Track progress from 0% to 100%
- Review progress across all goals and by area
- Use the app offline with local-only storage
- Follow your Android light or dark appearance
- Responsive layouts for phones and larger screens

## Classification

- App or game: App
- Category: Productivity
- Ads: No
- App access: All functionality is available without login or special access
- Target audience assumption: Adults (18 and over); confirm in Play Console
- News app: No
- Government app: No
- Financial features: None
- Health features: None; the Health label is only an organizational category

## Data safety draft

- Does the app collect user data? No
- Does the app share user data with third parties? No
- Account creation: None
- Data transmitted off device by the app: None in builds without a Sentry key.
  A build made with `SENTRY_DSN` sends crash logs (App info and performance →
  Crash logs; diagnostics, not shared, not used for tracking). Update this
  declaration to "collects crash logs" before distributing such a build.
- User deletion control: Individual deletion and **Clear all goals** in Settings
- Privacy policy URL: `<PUBLIC_PRIVACY_POLICY_URL>`

The URL placeholder is a release blocker. Publish [PRIVACY.md](./PRIVACY.md) on
an accessible, non-editable public page and verify the final URL before filling
the Play Console form.

## Release notes

First release: create and organize goals, track progress, mark goals complete,
and review progress across every area. Goal data stays local to the device.
Includes system light/dark appearance and responsive phone/tablet layouts.

## Store assets

| Asset | File | Play use |
|---|---|---|
| App icon | `assets/store/icon-512.png` | 512×512, 32-bit PNG with alpha |
| Feature graphic | `assets/store/feature-graphic-1024x500.png` | 1024×500, 24-bit PNG without alpha |
| Screenshot 1 | `assets/store/screenshots/phone-goals-light.png` | Phone, 1080×1920, 24-bit PNG |
| Screenshot 2 | `assets/store/screenshots/phone-progress-light.png` | Phone, 1080×1920, 24-bit PNG |
| Screenshot 3 | `assets/store/screenshots/phone-editor-light.png` | Phone, 1080×1920, 24-bit PNG |
| Screenshot 4 | `assets/store/screenshots/phone-settings-light.png` | Phone, 1080×1920, 24-bit PNG |
| Optional screenshot | `assets/store/screenshots/phone-progress-dark.png` | Phone dark mode, 1080×1920, 24-bit PNG |
| QA evidence only | `assets/store/screenshots/tablet-goals-light.png` | Responsive Goals layout; do not upload as the only tablet screenshot |

Suggested screenshot alt text, each under 140 characters:

1. Goal list showing overall progress, active goals, categories, and offline status.
2. Trail review showing 50 percent progress across two locally stored goals.
3. Edit goal screen with category, target date, notes, and progress controls.
4. Settings explaining local storage, no account, no ads, and no analytics.
5. Trail review in Android dark mode.
