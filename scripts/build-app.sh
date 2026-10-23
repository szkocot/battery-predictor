#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
app_version="${APP_VERSION:-$(cat VERSION)}"
build_number="${APP_BUILD_NUMBER:-1}"
if [[ ! "$app_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || [[ ! "$build_number" =~ ^[0-9]+$ ]]; then
    echo "Expected APP_VERSION as X.Y.Z and APP_BUILD_NUMBER as an integer." >&2
    exit 1
fi
swift build -c release "$@"
bin_dir="$(swift build -c release --show-bin-path "$@")"
app="$(pwd)/dist/Battery Predictor.app"
mkdir -p "$app/Contents/MacOS"
mkdir -p "$app/Contents/Resources"
cp "$bin_dir/BatteryPredictor" "$app/Contents/MacOS/BatteryPredictor"
swift scripts/generate-icon.swift dist/AppIcon.iconset "$app/Contents/Resources/AppIcon.icns"
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>CFBundleName</key><string>Battery Predictor</string>
    <key>CFBundleDisplayName</key><string>Battery Predictor</string>
    <key>CFBundleIdentifier</key><string>com.szkocot.battery-predictor</string>
    <key>CFBundleExecutable</key><string>BatteryPredictor</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundleShortVersionString</key><string>0.2.0</string>
    <key>CFBundleVersion</key><string>2</string>
    <key>LSMinimumSystemVersion</key><string>13.0</string>
    <key>LSUIElement</key><true/>
    <key>NSHighResolutionCapable</key><true/>
</dict></plist>
PLIST
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $app_version" "$app/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "$app/Contents/Info.plist"
codesign --force --sign - "$app"
printf 'Built: %s\n' "$app"
