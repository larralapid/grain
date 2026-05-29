# Repository Guidelines

## Project Structure & Module Organization
`grain/` contains the app target: models in `grain/Models`, services in `grain/Services`, and SwiftUI screens in `grain/Views` with feature subfolders such as `LaunchPOC/` and `ScanPOC/`. Shared app entry points and theme files live in `grain/grainApp.swift`, `grain/ContentView.swift`, and `grain/GrainTheme.swift`. Unit tests are in `grainTests/`, UI tests are in `grainUITests/`, docs are in `docs/`, and visual references live in `screenshots/`.

## Build, Test, and Development Commands
Open the project in Xcode with `open grain.xcodeproj`.

Build the app from Terminal:
```sh
xcodebuild -project grain.xcodeproj -scheme grain -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Run unit and UI tests:
```sh
xcodebuild -project grain.xcodeproj -scheme grain -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Use Xcode for everyday iteration, previews, and camera-related flows that are easier to validate on a simulator or device.

## Coding Style & Naming Conventions
Use Swift 5.9+ and standard SwiftUI patterns. Indent with 4 spaces. Prefer `struct` for views and model helpers unless reference semantics are required. Use `PascalCase` for types, `camelCase` for properties and methods, and clear enum cases such as `transactionType`. Keep files focused by feature or domain. Favor small view components over large monolithic screens.

## Testing Guidelines
Unit tests use the Swift `Testing` framework in `grainTests/grainTests.swift`; UI tests use `XCTest` in `grainUITests/`. Name unit tests descriptively, for example `receiptInitSetsAllRequiredFields()`, and UI tests with `test...` prefixes such as `testLaunchPerformance()`. Add or update tests for model changes, parsing logic, and navigation changes. Run the full `xcodebuild ... test` command before opening a PR.

## Commit & Pull Request Guidelines
Recent commits use short imperative summaries, often with scope first, for example `Project setup: docs, CLAUDE.md, skills, load time POCs, test suite (#29)`. Follow that pattern: lead with the feature or fix, keep it specific, and reference the issue or PR when applicable. PRs should include a concise description, linked issue, test notes, and screenshots for visible UI changes.

## Configuration Notes
Do not commit local build output or user-specific Xcode data. Keep shared Xcode scheme files tracked, and prefer repository docs in `docs/` for architecture or product decisions.
