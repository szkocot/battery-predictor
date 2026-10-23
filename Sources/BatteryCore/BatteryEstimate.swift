public enum BatteryEstimate {
    public static func title(seconds: Double, onExternalPower: Bool = false) -> String {
        let hours = (seconds / 3600).rounded(.down)
        guard !onExternalPower, seconds.isFinite, seconds >= 0,
              hours < Double(Int.max) else { return "-1h" }
        return "\(Int(hours))h"
    }
}
