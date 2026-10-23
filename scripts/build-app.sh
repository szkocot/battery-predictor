#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
swift build -c release "$@"
bin_dir="$(swift build -c release --show-bin-path "$@")"
app="$(pwd)/dist/Battery Predictor.app"
mkdir -p "$app/Contents/MacOS"
cp "$bin_dir/BatteryPredictor" "$app/Contents/MacOS/BatteryPredictor"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>CFBundleName</key><string>Battery Predictor</string>
    <key>CFBundleDisplayName</key><string>Battery Predictor</string>
    <key>CFBundleIdentifier</key><string>com.szkocot.battery-predictor</string>
    <key>CFBundleExecutable</key><string>BatteryPredictor</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>0.1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
codesign --force --sign - "$app"
printf 'Built: %s\n' "$app"
