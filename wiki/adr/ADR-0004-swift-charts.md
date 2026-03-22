# ADR-0004: Use Swift Charts for analytics visualization

**Date**: 2025  
**Status**: Accepted

## Context

The analytics feature requires rendering spending breakdowns as charts (bar charts by category, brand, merchant) with period selectors (weekly/monthly/quarterly/yearly). Options considered:

- **Swift Charts** — Apple-native, SwiftUI-native, iOS 16+, declarative API
- **Charts.js via WKWebView** — web-based, flexible, awkward SwiftUI integration
- **DGCharts (formerly Charts)** — popular open-source Swift library, UIKit-based
- **Custom `Canvas` drawing** — maximum control, significant implementation effort

Given the zero-external-dependencies decision (ADR-0003) and the iOS 17 deployment target (ADR-0001), Swift Charts is the natural choice.

## Decision

Use **Swift Charts** (`import Charts`) for all analytics visualisation.

## Consequences

**Easier**
- Fully declarative — chart definitions compose with SwiftUI views naturally.
- Automatic accessibility (VoiceOver chart summaries) with no extra work.
- Dark mode, dynamic type, and localisation handled by the framework.
- No additional dependency (see ADR-0003).

**Harder**
- Swift Charts has limited chart types compared to mature libraries (no pie charts, no gauge charts natively in early versions).
- Complex interactions (brush selection, crosshair tooltips) require significant custom implementation.
- iOS 16 minimum for Swift Charts is already covered by the iOS 17 deployment target.
