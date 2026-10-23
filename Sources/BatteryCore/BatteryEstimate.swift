public struct BatteryEstimate {
    private let minutes: Int?
    public let isVisible: Bool

    public init(seconds: Double, onExternalPower: Bool = false, isCharging: Bool = false) {
        let wholeMinutes = (seconds / 60).rounded(.down)
        if !onExternalPower, seconds.isFinite, seconds >= 0, wholeMinutes < Double(Int.max) {
            minutes = Int(wholeMinutes)
        } else {
            minutes = nil
        }
        isVisible = !isCharging
    }

    public var title: String {
        guard let minutes else { return "-1h" }
        return minutes < 60 ? "\(minutes)m" : "\(minutes / 60)h"
    }

    public var detailedTitle: String {
        guard let minutes else { return "-1h" }
        return "\(minutes / 60)h \(minutes % 60)m"
    }
}
