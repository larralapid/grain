# ADR-0001: Use SwiftUI + SwiftData as the app framework

**Date**: 2025  
**Status**: Accepted

## Context

Grain is a greenfield iOS app targeting iOS 17+. The team needed to choose a UI and persistence stack. The main candidates were:

- **UIKit + Core Data** — battle-tested, maximum flexibility, extensive documentation
- **SwiftUI + Core Data** — modern UI with proven persistence
- **SwiftUI + SwiftData** — fully declarative UI and persistence, requires iOS 17+

The app has a small scope (receipt scanning, expense tracking) and no requirement to support iOS versions older than 17.

## Decision

Use **SwiftUI** for all views and **SwiftData** for persistence.

SwiftData's `@Model` macro and `@Query` property wrapper eliminate nearly all persistence boilerplate and compose naturally with SwiftUI's reactive model. The iOS 17 deployment target was already chosen for VisionKit's `DataScannerViewController` capability.

## Consequences

**Easier**
- Model definitions are a single annotated Swift struct/class — no `.xcdatamodeld` file to maintain.
- `@Query` in views auto-refreshes on model changes without manual observation.
- No impedance mismatch between UI layer and persistence layer.

**Harder**
- SwiftData is immature; bugs and missing features (e.g., complex predicates, migration tooling) require workarounds.
- iOS 17 minimum cuts off ~15% of the active iOS install base at time of decision.
- Automated testing of SwiftData models is less documented than Core Data unit test patterns.
