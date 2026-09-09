# Android Release Runbook

The release is not complete until every required item below has evidence. Do
not upload an APK signed with a debug key and do not claim a production release
from a local build.

## Fixed identity

- App name: Goal Tracker
- Package ID: `com.bookchaowalit.goaltracker`
- Version: `1.0.0+1`
- Minimum SDK: 24
- Target SDK: 36
- Default language: English (United States)

Confirm the package ID in Play Console before creating the app. A published
package ID cannot be changed.

## One-time Play Console setup

- [ ] Confirm the signed-in developer account and organization profile
- [ ] Confirm developer name, public support email, and contact details
- [ ] Create the app with the fixed package ID
- [ ] Accept Play App Signing
- [ ] Create a dedicated upload key; store the keystore and passwords only in
      the approved secret manager
- [ ] Create ignored `android/key.properties` locally from secret references
- [ ] Publish `PRIVACY.md` and replace `<PUBLIC_PRIVACY_POLICY_URL>`
- [ ] Complete Data safety, content rating, target audience, ads, app access,
      and other policy declarations using `STORE-LISTING.md`

## Build and verify

```bash
flutter pub get
flutter analyze
flutter test
flutter build appbundle --release
sha256sum build/app/outputs/bundle/release/app-release.aab
```

The Gradle configuration deliberately stops the release build when upload-key
configuration is absent. Keep `android/key.properties`, `*.jks`, and
`*.keystore` out of Git.

Before upload, verify the AAB's package, version, target SDK, signing
certificate, and SHA-256. Use an immutable CI artifact from an explicitly
approved commit whenever possible.

## Play rollout

- [ ] Upload the signed AAB to Internal testing
- [ ] Resolve automated pre-launch report, policy, and Android vitals findings
- [ ] Complete a human smoke test from the Play-delivered build
- [ ] Promote the exact tested artifact to Production
- [ ] Start with a 10% staged rollout
- [ ] Check crashes, ANRs, reviews, and policy status before 50% and 100%
- [ ] Record the Play version code, artifact SHA-256, release time, and rollout
      state in `TEST-EVIDENCE.md`

Organization accounts are not subject to the new-personal-account 12-testers
for 14-days gate, but internal testing and review evidence are still required
by this runbook.

## Rollback

Google Play cannot roll users back to a lower version code. If production has
a critical issue, halt the staged rollout, prepare a fixed build with a higher
version code, repeat verification, and submit the hotfix. Preserve the last
known-good source commit and signing identity.

