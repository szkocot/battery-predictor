# Launch at Login

Approved request: make Battery Predictor auto-start at login.

Design: use macOS 13+ SMAppService.mainApp. Register on first bundled-app launch; persist that the attempt was made to respect subsequent opt-outs. Include a checkable menu item, refresh its status when opening the menu, and direct pending approval to System Settings. Surface registration errors without pretending registration succeeded. Unbundled command-line runs do not register.

Implementation: LoginItemController owns registration and menu status; AppDelegate connects it to launch and menu lifecycle. Update app version and README. Verify with the existing test suite, release build and signature checks. Login/logout behavior requires a local interactive session.
