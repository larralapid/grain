# ADR-0003: Zero external dependencies — Apple frameworks only

**Date**: 2025  
**Status**: Accepted

## Context

Many iOS apps accumulate third-party libraries (Alamofire, Realm, Firebase, etc.) for convenience. Each dependency adds:

- Binary size
- Supply-chain security risk
- Upgrade/compatibility maintenance burden
- Potential App Store review concerns

Grain's functionality (camera capture, OCR, persistence, analytics, charts) maps cleanly onto Apple's native frameworks: VisionKit, Vision, SwiftData, Swift Charts.

## Decision

Use **only Apple-provided frameworks**. No Swift Package Manager dependencies, no CocoaPods, no Carthage.

Specifically, the app uses:
- `VisionKit` — camera document scanning
- `Vision` — OCR text recognition
- `SwiftData` — persistence
- `Charts` (Swift Charts) — analytics visualisation
- `UIKit` — camera presentation layer

## Consequences

**Easier**
- No `Package.resolved` conflicts or SPM resolution failures.
- Smaller binary.
- All frameworks are covered by Apple's security review.
- App Store submission is straightforward.

**Harder**
- Some features that a library would provide in minutes require custom implementation (e.g., CSV export, bank OFX parsing).
- The team cannot use community-maintained parsers or utilities.
- If Apple's frameworks have bugs or missing features, there is no workaround short of writing custom code.
