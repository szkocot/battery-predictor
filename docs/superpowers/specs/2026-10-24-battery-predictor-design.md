# Battery Predictor

Approved scope: native macOS menu bar utility displaying whole remaining hours (for example `9h`) and exactly `-1h` when unavailable. A menu shows battery percentage and charging status and provides Quit.

## Approach

Use Swift, AppKit and IOKit, with no external dependencies. macOS provides the remaining-time prediction; avoid inventing an estimate before sufficient discharge information exists. A custom discharge-history model would add calibration and persistence complexity. Cross-platform UI adds unnecessary weight for this macOS-only utility. Native Swift was approved by the user.

## Behavior and constraints

- macOS 13 or later; no Dock icon or main window.
- Floor available seconds to whole hours: 9h 59m becomes `9h`, under one hour becomes `0h`.
- Unknown, unlimited, negative or non-finite estimates display `-1h`. External power also displays `-1h`, because discharge runtime is unavailable.
- Update on power-source changes, wake and every 60 seconds.
- Show internal battery percentage, or unavailable if there is no battery.
- No network access, telemetry, persistent history or permissions needed.
- Deliver a locally buildable `.app`; distribution signing and notarization are outside this first version.
