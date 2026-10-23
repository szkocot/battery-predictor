# Battery Predictor Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build the approved native menu bar battery utility.

**Architecture:** A pure BatteryCore model formats the OS estimate. An AppKit executable reads IOKit power sources and maintains a status item and menu. A script packages the executable as an accessory app.

**Tech Stack:** Swift Package Manager, AppKit, IOKit, XCTest, macOS 13+.

**Spec:** ../specs/2026-10-24-battery-predictor-design.md

## Global Constraints

Whole hours only, `-1h` for unavailable estimates. No external dependencies. No Dock icon. Refresh on power changes, wake and every 60 seconds.

## Review Focus

Unknown and unlimited estimates; invalid numeric input; less than an hour remaining; charging; machines without an internal battery.

### Task 1: Estimate model

Files: Package.swift, Sources/BatteryCore/BatteryEstimate.swift, Tests/BatteryCoreTests/BatteryEstimateTests.swift.

Interface: `BatteryEstimate.title(seconds: Double, onExternalPower: Bool) -> String`.

- [ ] Write tests for 9h, fractional-hour flooring, 0h, negative sentinels, NaN/infinity, and external power.
- [ ] Run `swift test` and observe missing implementation failure.
- [ ] Implement validated conversion and run `swift test` successfully.

### Task 2: App and packaging

Files: Sources/BatteryPredictor/main.swift, scripts/build-app.sh, README.md, .gitignore.

- [ ] Connect IOKit estimate and internal-battery details to NSStatusItem and its menu; add timer, power-change callback, wake observer and Quit.
- [ ] Package a release executable with LSUIElement and macOS minimum version in Info.plist; ad-hoc sign for local use.
- [ ] Run tests, release build, plist validation and signature verification. Smoke-test the executable's power snapshot via `--diagnostics` without launching UI.
- [ ] Review source for observer lifecycle, missing-battery behavior and integer conversion safety.
- [ ] Commit and push the verified version using the writable temporary checkout, since workspace Git metadata is read-only.
