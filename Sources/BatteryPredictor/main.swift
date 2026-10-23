import AppKit
import BatteryCore
import IOKit.ps

struct PowerSnapshot {
    let seconds: Double
    let percentage: Int?
    let externalPower: Bool
    let status: String

    var title: String {
        BatteryEstimate.title(seconds: seconds, onExternalPower: externalPower)
    }

    static func read() -> PowerSnapshot {
        let seconds = IOPSGetTimeRemainingEstimate()
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else {
            return PowerSnapshot(seconds: -1, percentage: nil, externalPower: false, status: "Battery unavailable")
        }
        for source in sources {
            guard let details = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any],
                  details[kIOPSTypeKey] as? String == kIOPSInternalBatteryType else { continue }
            let current = (details[kIOPSCurrentCapacityKey] as? NSNumber)?.doubleValue
            let maximum = (details[kIOPSMaxCapacityKey] as? NSNumber)?.doubleValue
            var percentage: Int?
            if let current, let maximum, current.isFinite, maximum.isFinite, maximum > 0 {
                percentage = Int(min(100, max(0, current / maximum * 100)).rounded())
            }
            let external = details[kIOPSPowerSourceStateKey] as? String == kIOPSACPowerValue
            let charging = details[kIOPSIsChargingKey] as? Bool == true
            let status = charging ? "Charging" : (external ? "Connected to power" : "On battery")
            return PowerSnapshot(seconds: seconds, percentage: percentage, externalPower: external, status: status)
        }
        return PowerSnapshot(seconds: -1, percentage: nil, externalPower: false, status: "No internal battery")
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var powerSource: CFRunLoopSource?
    private var wakeObserver: NSObjectProtocol?
    private let batteryItem = NSMenuItem(title: "Battery: unavailable", action: nil, keyEquivalent: "")
    private let powerItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let loginItem = LoginItemController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular)
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(NSMenuItem(title: "Battery Predictor", action: nil, keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(batteryItem)
        menu.addItem(powerItem)
        menu.addItem(.separator())
        menu.addItem(loginItem.menuItem)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Battery Predictor", action: #selector(quitApp), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu
        refresh()
        loginItem.configureOnFirstLaunch()
        loginItem.refresh()

        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        timer?.tolerance = 5
        let context = Unmanaged.passUnretained(self).toOpaque()
        powerSource = IOPSNotificationCreateRunLoopSource({ context in
            guard let context else { return }
            Unmanaged<AppDelegate>.fromOpaque(context).takeUnretainedValue().refresh()
        }, context)?.takeRetainedValue()
        if let powerSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), powerSource, .commonModes)
        }
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification, object: nil, queue: .main
        ) { [weak self] _ in self?.refresh() }
    }

    private func refresh() {
        let snapshot = PowerSnapshot.read()
        statusItem.button?.title = snapshot.title
        statusItem.button?.toolTip = "Battery Predictor — \(snapshot.status)"
        statusItem.button?.setAccessibilityLabel("Battery Predictor: \(snapshot.title)")
        batteryItem.title = snapshot.percentage.map { "Battery: \($0)%" } ?? "Battery: unavailable"
        powerItem.title = snapshot.status
    }

    @objc private func quitApp() { NSApplication.shared.terminate(nil) }

    func menuWillOpen(_ menu: NSMenu) { loginItem.refresh() }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        if let powerSource { CFRunLoopSourceInvalidate(powerSource) }
        if let wakeObserver { NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver) }
    }
}

if CommandLine.arguments.contains("--diagnostics") {
    let snapshot = PowerSnapshot.read()
    print("Estimate: \(snapshot.title)")
    print("Battery: \(snapshot.percentage.map { "\($0)%" } ?? "unavailable")")
    print("Status: \(snapshot.status)")
} else {
    let app = NSApplication.shared
    let delegate = AppDelegate()
    app.setActivationPolicy(.accessory)
    app.delegate = delegate
    withExtendedLifetime(delegate) { app.run() }
}
