# Battery Predictor

A simple macOS menu bar utility that estimates remaining battery life in hours.

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

The label shows whole hours rounded down: 9 hours 59 minutes is `9h`; less than an hour is `0h`. Unavailable estimates display `-1h`, including when connected to power or while macOS is calculating an estimate after unplugging or waking. Estimates come from macOS and change with your workload.

Updates happen on power-source changes, wake, and every minute. No network access, telemetry, or third-party dependencies.

For a power-reading diagnostic without launching the UI:

```sh
swift run BatteryPredictor --diagnostics
```

The build script signs the app ad hoc for local use. Distribution to other Macs requires appropriate signing and notarization.
