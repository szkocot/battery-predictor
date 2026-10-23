import XCTest
@testable import BatteryCore

final class BatteryEstimateTests: XCTestCase {
    func testWholeHours() {
        XCTAssertEqual(BatteryEstimate.title(seconds: 9 * 3600), "9h")
        XCTAssertEqual(BatteryEstimate.title(seconds: 9 * 3600 + 3599), "9h")
    }

    func testUnderOneHour() {
        XCTAssertEqual(BatteryEstimate.title(seconds: 3599), "0h")
        XCTAssertEqual(BatteryEstimate.title(seconds: 0), "0h")
    }

    func testUnavailableEstimates() {
        for seconds in [-1.0, -2.0, .nan, .infinity, -.infinity, .greatestFiniteMagnitude] {
            XCTAssertEqual(BatteryEstimate.title(seconds: seconds), "-1h")
        }
    }

    func testExternalPowerHasNoDischargeEstimate() {
        XCTAssertEqual(BatteryEstimate.title(seconds: 32400, onExternalPower: true), "-1h")
    }
}
