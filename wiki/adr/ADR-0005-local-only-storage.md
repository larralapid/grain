# ADR-0005: Local-only storage; defer CloudKit sync

**Date**: 2025  
**Status**: Accepted

## Context

Receipt and expense data is sensitive financial information. The app needs to decide where data lives and whether it syncs across devices. Options considered:

- **Local only (SwiftData without CloudKit)** — simple, private, no backend needed
- **CloudKit sync via SwiftData** — cross-device sync, Apple-managed infrastructure, free tier
- **Custom backend (REST API + database)** — full control, cross-platform potential, significant infrastructure work

The project is at a proof-of-concept stage. Cross-device sync and cloud backup are valuable features but not critical for an MVP.

A CloudKit entitlement (`grain.entitlements`) was added to the project, indicating sync was considered but not implemented.

## Decision

Launch with **local-only SwiftData storage**. The CloudKit entitlement is present but inactive. CloudKit sync will be enabled in a future release once the data model is stable.

## Consequences

**Easier**
- No backend infrastructure to maintain.
- No network requests in the data path — faster, works offline.
- No authentication or account management needed for v1.
- Privacy: data never leaves the device unless the user explicitly exports it.

**Harder**
- Data is lost if the user loses their device and has no iTunes/iCloud device backup.
- No cross-device access (phone + iPad).
- Enabling CloudKit later requires the SwiftData model to be stable; schema migrations after CloudKit sync is live are more complex.

## Future

When CloudKit sync is enabled, a new ADR should document the migration strategy, conflict resolution approach, and any model changes required.
