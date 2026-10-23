# Automated release builds

Request: each GitHub release has an app artifact; first release is 0.1.0.

Design: release-published workflow on macos-15 runs tests, builds universal arm64/x86_64 app, validates code signature and embedded version, and uploads a ZIP plus SHA-256 checksum to the existing release. Manual dispatch supports recovery. Release tags vX.Y.Z supply the version; VERSION is the local default. No signing credentials are available, so preserve ad-hoc signing and document the macOS approval requirement.

Plan: add workflow and version handling; verify local version and universal packaging; review; push to GitHub; publish v0.1.0; monitor Actions and confirm both release assets exist. Do not claim success based only on workflow configuration.
