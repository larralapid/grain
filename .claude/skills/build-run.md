---
name: build-run
description: Build, test, and run grain on a simulator or device — with the exact verified commands
user_invocable: true
---

# Build & Run Skill

Canonical commands for building, testing, and running grain. Use these instead of
guessing destinations (a wrong/empty destination is the usual cause of "No Destinations").

## Build (simulator)

```bash
xcodebuild build \
  -scheme grain -project grain.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -configuration Debug CODE_SIGNING_ALLOWED=NO
```

A successful run ends with `** BUILD SUCCEEDED **`. Pipe through `tail -40` —
`-quiet` can mask scheme-load errors while still returning exit code 0.

## Test

```bash
xcodebuild test \
  -scheme grain -project grain.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

## Run on a booted simulator

```bash
xcrun simctl boot "iPhone 17" 2>/dev/null || true
open -a Simulator
xcodebuild build -scheme grain -project grain.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 17' -configuration Debug CODE_SIGNING_ALLOWED=NO
APP=$(xcrun simctl get_app_container booted larra.grain app 2>/dev/null)
xcrun simctl install booted "$APP" && xcrun simctl launch booted larra.grain
```

Bundle id: `larra.grain`. Deployment target: iOS 17.0.

## Run on a physical iPhone

The device must be **connected, unlocked, and trusted**, with **Developer Mode** on
(`Settings → Privacy & Security → Developer Mode`). Check status:

```bash
xcrun xctrace list devices        # look for your phone under "Devices", not "Devices Offline"
```

If a device shows under **Devices Offline**, it is paired but unreachable — reconnect the
cable (or same Wi-Fi for wireless debugging) and unlock it.

## "No Destinations" troubleshooting

If Xcode shows **No Destinations** (no simulators either), the selected **scheme failed to
load** — usually malformed XML in `grain.xcodeproj/xcshareddata/xcschemes/*.xcscheme`.
Validate every `BuildableReference` has a `ReferencedContainer = "container:grain.xcodeproj">`
line and a closing `>`. Confirm the project parses:

```bash
plutil -lint grain.xcodeproj/project.pbxproj
xcodebuild -list -project grain.xcodeproj   # should list schemes with no "load error" warning
```
