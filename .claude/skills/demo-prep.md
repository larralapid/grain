---
name: demo-prep
description: Prepare grain for a demo or pitch — seed realistic data and capture screenshots
user_invocable: true
---

# Demo Prep Skill

For producing a clean, screenshot-ready build (e.g. for the accelerator submission).

## Seed realistic data

`DemoDataSeeder.seedIfNeeded(in:)` populates ~23 realistic receipts with items, brands,
products, and price history. It runs automatically when the store is empty (DEBUG). To
force a clean reseed, erase the simulator app data first:

```bash
xcrun simctl uninstall booted larra.grain   # wipes the SwiftData store
# then rebuild + reinstall (see /build-run)
```

## Capture screenshots

```bash
mkdir -p screenshots
xcrun simctl io booted screenshot "screenshots/$(date +%H%M%S)-screen.png"
```

Capture the high-signal screens for a pitch:
1. Receipts list (populated, grouped by month)
2. Receipt detail with the thermal proof sheet
3. Analytics — category / brand / merchant charts
4. Product index + a single product's price history
5. The scan → proof-sheet → **SAVE RECEIPT** flow (now functional)

## Tips

- Use **iPhone 17** or **iPhone 17 Pro** for current-gen framing.
- Toggle light/dark via the in-app `AppearanceManager` to show the adaptive theme.
- Record a short flow with `xcrun simctl io booted recordVideo screenshots/demo.mov`.
- Keep final assets in `screenshots/` (already referenced by `README.md` and `CHANGELOG.md`).
