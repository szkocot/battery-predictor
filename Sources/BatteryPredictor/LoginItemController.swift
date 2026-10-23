import AppKit
import ServiceManagement

final class LoginItemController: NSObject, NSMenuItemValidation {
    let menuItem = NSMenuItem(title: "Launch at Login", action: nil, keyEquivalent: "")
    private let configuredKey = "launchAtLoginConfigured"

    override init() {
        super.init()
        menuItem.target = self
        menuItem.action = #selector(toggle)
    }

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }

    func configureOnFirstLaunch() {
        guard Bundle.main.bundleURL.pathExtension == "app" else {
            menuItem.isEnabled = false
            return
        }
        guard !UserDefaults.standard.bool(forKey: configuredKey) else { return }
        // Record the attempt so relaunching never overrides a later user choice.
        UserDefaults.standard.set(true, forKey: configuredKey)
        if SMAppService.mainApp.status == .notRegistered {
            setEnabled(true)
        }
    }

    func refresh() {
        let status = SMAppService.mainApp.status
        menuItem.state = status == .enabled ? .on : (status == .requiresApproval ? .mixed : .off)
        menuItem.title = status == .requiresApproval ? "Launch at Login (Approve in Settings…)" : "Launch at Login"
    }

    @objc private func toggle() {
        if SMAppService.mainApp.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        } else {
            setEnabled(SMAppService.mainApp.status != .enabled)
        }
        refresh()
    }

    private func setEnabled(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Couldn’t update Launch at Login"
            alert.informativeText = "Keep Battery Predictor in Applications and try again. \(error.localizedDescription)"
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
}
