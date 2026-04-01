# Grain Project Plan (PM)

Last updated: 2026-04-01

Primary tracker issue: [#58](https://github.com/larralapid/grain/issues/58)

## Goals

- Deliver an MVP that is reliable for real receipt tracking.
- Keep scope aligned with local-only iOS product direction.
- Improve repository hygiene so work is easy to prioritize and ship.

## Work Plan With Issue Links

### Sprint 1: Backlog Hygiene and Delivery Control

- [x] Close completed infra issues and mark outcomes in comments.
  - Related: [#37](https://github.com/larralapid/grain/issues/37), [#38](https://github.com/larralapid/grain/issues/38), [#39](https://github.com/larralapid/grain/issues/39), [#28](https://github.com/larralapid/grain/issues/28)
- [x] Defer non-MVP issues with explicit not-planned rationale.
  - Related: [#22](https://github.com/larralapid/grain/issues/22), [#23](https://github.com/larralapid/grain/issues/23), [#24](https://github.com/larralapid/grain/issues/24), [#25](https://github.com/larralapid/grain/issues/25), [#27](https://github.com/larralapid/grain/issues/27), [#2](https://github.com/larralapid/grain/issues/2)
- [ ] Merge or close open documentation PR quickly.
  - Related: [PR #47](https://github.com/larralapid/grain/pull/47), [PR #55](https://github.com/larralapid/grain/pull/55)

### Sprint 2: MVP Usability Gaps

- [ ] Add manual receipt entry flow from receipt list plus action.
  - Related: [#58](https://github.com/larralapid/grain/issues/58), [#3](https://github.com/larralapid/grain/issues/3)
- [ ] Wire scan proof edit action so users can fix OCR output before save.
  - Related: [#58](https://github.com/larralapid/grain/issues/58), [#4](https://github.com/larralapid/grain/issues/4)
- [ ] Persist original captured image into receipt imageData.
  - Related: [#58](https://github.com/larralapid/grain/issues/58), [#3](https://github.com/larralapid/grain/issues/3)

### Sprint 3: Reliability and Quality

- [ ] Add parser regression test set for multiple receipt formats.
  - Related: [#58](https://github.com/larralapid/grain/issues/58), [#4](https://github.com/larralapid/grain/issues/4)
- [ ] Replace print-only error handling with user-facing alerts in key scan/save paths.
  - Related: [#58](https://github.com/larralapid/grain/issues/58), [#3](https://github.com/larralapid/grain/issues/3)
- [ ] Validate analytics totals and date-range aggregation with unit tests.
  - Related: [#58](https://github.com/larralapid/grain/issues/58), [#3](https://github.com/larralapid/grain/issues/3)

### Sprint 4: Optional MVP+ Extensions

- [ ] Define lightweight export scope and ship minimal CSV export.
  - Related: [#5](https://github.com/larralapid/grain/issues/5), [#26](https://github.com/larralapid/grain/issues/26)
- [ ] Begin bank transaction linking only after import path exists.
  - Related: [#1](https://github.com/larralapid/grain/issues/1)

## Definition of MVP Done

- [ ] User can scan, review/edit, and save receipts reliably.
- [ ] User can manually enter a receipt when OCR fails.
- [ ] User sees clear error messages when save/parse fails.
- [ ] Analytics view reflects stored receipt totals correctly.
- [ ] Open issue backlog is scoped to MVP and near-term priorities.

## PM Operating Cadence

- [ ] Weekly: close stale branches and stale issues.
- [ ] Weekly: update this plan with completed checkboxes.
- [ ] Per PR: ensure linked issue exists and status is updated.
