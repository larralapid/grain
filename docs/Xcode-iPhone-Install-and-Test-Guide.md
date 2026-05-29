# Xcode iPhone Install and Test Guide

Last updated: 2026-04-01

This guide is a practical checklist for reinstalling Grain on your physical iPhone and validating a clean test run.

## Before You Start

- Mac has latest stable Xcode installed.
- iPhone is on a supported iOS version for the project target.
- You are signed into Xcode with your Apple ID.
- iPhone is connected by cable for first install.
- iPhone is unlocked and trusted by the Mac.

## One-Time Device Setup

1. Connect iPhone to Mac.
2. Open Xcode.
3. Go to Window > Devices and Simulators.
4. Select your iPhone and confirm it is available for development.
5. If prompted on phone, tap Trust and enter passcode.
6. Wait for Xcode to finish preparing device support files.

## Project Signing Setup

1. Open grain.xcodeproj.
2. Select the grain project in navigator.
3. Select the grain target.
4. Open Signing and Capabilities.
5. Enable Automatically manage signing.
6. Choose your Team.
7. Confirm Bundle Identifier is unique under your team.
8. Keep capabilities minimal for local testing.

## Clean Reinstall Flow (Recommended)

1. On iPhone, delete the existing Grain app.
2. In Xcode, Product > Clean Build Folder.
3. In Xcode toolbar, set run destination to your iPhone.
4. Press Run.
5. If iPhone shows a Developer Mode prompt, enable Developer Mode and restart iPhone.
6. Re-run from Xcode after restart.

## If App Will Not Launch (Common Fixes)

- Check iPhone Settings > Privacy and Security > Developer Mode is ON.
- Check iPhone Settings > General > VPN and Device Management and trust your developer certificate if needed.
- In Xcode, confirm Signing team and bundle identifier are valid.
- If signing errors persist:
  1. Xcode > Settings > Accounts, refresh account.
  2. Back in Signing and Capabilities, toggle Automatically manage signing OFF then ON.
  3. Rebuild and run.

## Recommended Manual Test Pass After Install

Use this short pass every time you reinstall:

1. Launch app from Xcode and confirm home tab appears.
2. Open Scan tab and capture one simple receipt.
3. Verify parsed merchant, subtotal, tax, and total look reasonable.
4. Save receipt and verify it appears in receipt list.
5. Open receipt detail and edit at least one field.
6. Open Analytics tab and confirm totals include new receipt.
7. Force close app and relaunch from phone icon to verify persistence.

## Best Practice Notes

- Use a real device for camera and OCR validation; simulator results are not enough.
- Keep at least one known-good sample receipt for regression checks.
- Test in normal and low-light conditions for OCR quality.
- Run one clean reinstall weekly to catch signing and deployment drift.

## Troubleshooting Log Template

Copy this block into your notes each test session:

Date:
Xcode version:
iOS version:
Branch/commit:
Install result:
Scan/save result:
Analytics result:
Errors observed:
Next action:
