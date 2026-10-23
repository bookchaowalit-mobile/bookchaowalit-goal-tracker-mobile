---
title: "Goal Tracker Mobile — KPI and Instrumentation Plan"
status: draft
created: 2026-10-23
updated: 2026-10-23
description: "How Goal Tracker Mobile would be measured once it has users; today only Sentry error reports exist."
template: architecture-docs templates/sdlc/kpi-and-instrumentation-plan.md
---

# Goal Tracker Mobile — KPI and Instrumentation Plan

## Document control

| Field | Value |
|---|---|
| Project / product | bookchaowalit-mobile/productivity-goal-tracker-mobile (no live URL; not store-released) |
| Version / status | 0.1 / **draft** — definitions only; no analytics is live, no baselines |
| Metric owner | Owner (bookchaowalit) |
| AI maker | Claude Code (b-tier-b session, 2026-10-23) |
| AI reviewer | not yet reviewed |
| Charter objective | OBJ-01 below (portfolio RC; no charter document) |
| Analytics source of truth | none yet. Owner decision **D4** (2026-10-23) chose the PostHog free tier, but no PostHog project or key exists, so nothing is sent. The only live signal is Sentry (org `personal-yu0`, project `productivity-goal-tracker-mobile`), errors only, and only from the CI release bundle, which is unsigned and not distributed |
| Dashboard | none |
| Next review | 2026-11-15 (Big Loop milestone M1) |

## KPI tree

```text
OBJ-01 Help someone keep a few goals moving, offline, without an account
  └─ KPI-O-01 Goal follow-through: goals updated again within 7 days of creation / goals created
       ├─ KPI-L-01 Goals completed (progress 100 %) per active user per 30 days
       ├─ KPI-L-02 Save success rate: successful writes / write attempts (rollback path)
       └─ KPI-G-01 Crash-affected launches: launches with a Sentry error / launches (must stay < 1%)
```

## KPI definitions

| KPI ID | Type | Formula | Unit | Min volume | Data source and event(s) | Baseline | Target | Alert | Cadence | Owner |
|---|---|---|---|---|---|---|---|---|---|---|
| KPI-O-01 | outcome | goals with a `goal_updated` ≤ 7 days after `goal_created` / `goal_created` | % | ≥ 50 created | planned events | not yet measured (no users) | ≥ 40% within 60 days of a first public build | < 25% over 30 days | monthly | Owner |
| KPI-L-01 | leading | count `goal_completed` / active users, 30 days | goals | ≥ 20 users | planned event | not yet measured | none set (descriptive) | — | monthly | Owner |
| KPI-L-02 | leading | 1 − `save_failed` / write attempts | % | ≥ 200 writes | planned event | not yet measured | ≥ 99.9% | < 99% | monthly | Owner |
| KPI-G-01 | guardrail | launches with ≥ 1 Sentry error / launches | % | ≥ 200 launches | Sentry issues (live) ÷ `app_opened` (planned) | not yet measured; error count today: 0 (no distributed build) | < 1% | any new issue in a release | per release | Owner |

Below the minimum volume a rate is reported as "not measurable". Launch counts need `app_opened`, so KPI-G-01 is
only an error count until analytics exists (Sentry session tracking is deliberately off).

## Event and data specification

| Event | Trigger | Properties | Personal data? | Emitted by | Status |
|---|---|---|---|---|---|
| `app_opened` | app reaches the first frame | app_version, layout (phone/tablet) | no | app | planned (D4: PostHog, no key yet) |
| `goal_created` | `GoalController.upsert` saves a new goal | category, has_due_date, has_note | no | app | planned (D4: PostHog, no key yet) |
| `goal_updated` | upsert of an existing goal succeeds | progress_bucket (0/25/50/75/100) | no | app | planned (D4: PostHog, no key yet) |
| `goal_completed` | progress reaches 100 % | days_since_created | no | app | planned (D4: PostHog, no key yet) |
| `save_failed` | `_persistOrRollback` rolls back | operation (upsert/delete/clear) | no | app | planned (D4: PostHog, no key yet) |
| Sentry error event | uncaught Dart error in a build with `SENTRY_DSN` | exception type, stack trace, app/OS/device model | no: user, request, breadcrumbs, extra, device name and exception messages are stripped (`lib/observability/crash_reporting.dart`, tested) | app | implemented |

Privacy rules:

- Never send goal titles, notes or any typed text. Categories, counts, buckets and booleans only.
- Adding any analytics event changes the app's promise ("no account, advertising, analytics, or cloud sync" in
  Settings, `PRIVACY.md`, the Play Data safety draft in `STORE-LISTING.md`) and all three must be updated
  **before** the build ships.
- Sentry retention follows the Sentry project default; data region is Sentry's (US). `PRIVACY.md` describes crash
  reports; the Data safety form must declare crash logs before a Sentry-enabled build is distributed.

## Dashboards and alerts

| Dashboard / alert | KPIs | Location | Status |
|---|---|---|---|
| Sentry issues for `productivity-goal-tracker-mobile` | KPI-G-01 (count only) | Sentry org `personal-yu0` | live, no traffic |
| Product dashboard | KPI-O-01, L-01, L-02 | — | planned (D4) |

## Instrumentation verification (before G10)

| # | Check | Result |
|---|---|---|
| 1 | Events fire once per action | not applicable yet (no events) |
| 2 | Counts reconcile | not applicable |
| 3 | No PII in payloads | Sentry scrubber covered by `test/crash_reporting_test.dart` |
| 4 | Dashboard renders | Sentry project exists; no product dashboard |
| 5 | Alerts reach a channel | not set up |
| 6 | Baselines | waived — dated action: capture after the first distributed build, or by 2026-12-31 decide that this RC stays unmeasured |
| 7 | Consent | not applicable (no analytics) |

## Change history of definitions

| Date | KPI ID | Change | Reason | Approved by |
|---|---|---|---|---|
| 2026-10-23 | all | first draft (D4 = PostHog free tier, no key yet) | b-tier-b L3 work | pending owner |
