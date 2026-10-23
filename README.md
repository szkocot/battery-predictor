# Battery Predictor

A simple macOS menu bar utility that estimates remaining battery life in hours.

## Download

Download the universal app ZIP from [GitHub Releases](https://github.com/szkocot/battery-predictor/releases), unzip it, and move **Battery Predictor.app** to Applications. It supports Apple Silicon and Intel Macs running macOS 13 or later. Release builds are ad-hoc signed, not notarized; macOS may require you to approve the app in System Settings → Privacy & Security on first open.

## Goals

- Show a clear remaining battery estimate in the menu bar.
- Respond to changes in power usage and charging state.
- Stay lightweight and handle unavailable estimates honestly.

## Build and run

Requires macOS 13+ and Xcode command line tools with Swift 5.9+.

```sh
swift test
bash scripts/build-app.sh
open "dist/Battery Predictor.app"
```

Move the built app to Applications if desired. It runs in the menu bar, with no Dock icon. Click its hours label for battery percentage, power status, and Quit.

## Launch at login

Move the app to Applications before opening it. On the first launch, it registers with macOS to start when you log in. Toggle **Launch at Login** in its menu to disable or re-enable this. If approval is required, click the menu item to open System Settings → General → Login Items and approve Battery Predictor. Your choice is preserved across launches, including changes made in System Settings.

The label shows whole hours rounded down: 9 hours 59 minutes is `9h`. Below one hour it shows whole minutes, such as `59m` (below one minute: `0m`). Click the label to see the full estimate, such as `17h 59m`.

While the battery is actively charging, the menu bar item hides automatically. It returns when charging stops; the app continues monitoring in the background. Unavailable estimates display `-1h`, including when connected to power without charging or while macOS is calculating an estimate after unplugging or waking. Estimates come from macOS and change with your workload.

The app icon and menu heading use the 🪫 emoji. The icon is rendered from Apple Color Emoji during the build, at standard and Retina icon sizes.

Updates happen on power-source changes, wake, and every minute. No network access, telemetry, or third-party dependencies.

For a power-reading diagnostic without launching the UI:

```sh
swift run BatteryPredictor --diagnostics
```

The build script signs the app ad hoc for local use. Distribution to other Macs requires appropriate signing and notarization.

## Releases

Publish a GitHub release with a tag such as `v0.1.0`. The release workflow tests the code, builds and verifies a universal app, and attaches `Battery-Predictor-v0.1.0-universal.zip` and its SHA-256 checksum. Assets appear when the workflow finishes. Failed builds can be retried from Actions, or via the workflow's manual tag input.

The release tag sets the app version automatically. `VERSION` supplies the version for local builds; update it when preparing a new version. For example:

```sh
gh release create v0.1.0 --target main --title "Battery Predictor 0.1.0" --generate-notes
```
