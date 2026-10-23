import XCTest
@testable import BatteryCore

final class BatteryEstimateTests: XCTestCase {
    func testWholeHours() {
        XCTAssertEqual(BatteryEstimate(seconds: 9 * 3600).title, "9h")
        XCTAssertEqual(BatteryEstimate(seconds: 9 * 3600 + 3599).title, "9h")
        XCTAssertEqual(BatteryEstimate(seconds: 3600).title, "1h")
    }

    func testUnderOneHour() {
        XCTAssertEqual(BatteryEstimate(seconds: 3599).title, "59m")
        XCTAssertEqual(BatteryEstimate(seconds: 60).title, "1m")
        XCTAssertEqual(BatteryEstimate(seconds: 59).title, "0m")
        XCTAssertEqual(BatteryEstimate(seconds: 0).title, "0m")
    }

    func testUnavailableEstimates() {
        for seconds in [-1.0, -2.0, .nan, .infinity, -.infinity, .greatestFiniteMagnitude] {
            let estimate = BatteryEstimate(seconds: seconds)
            XCTAssertEqual(estimate.title, "-1h")
            XCTAssertEqual(estimate.detailedTitle, "-1h")
        }
    }

    func testExternalPowerHasNoDischargeEstimate() {
        let estimate = BatteryEstimate(seconds: 32400, onExternalPower: true)
        XCTAssertEqual(estimate.title, "-1h")
        XCTAssertEqual(estimate.detailedTitle, "-1h")
        XCTAssertTrue(estimate.isVisible)
    }

    func testDetailedTimeUsesHoursAndMinutes() {
        XCTAssertEqual(BatteryEstimate(seconds: 17 * 3600 + 59 * 60 + 59).detailedTitle, "17h 59m")
        XCTAssertEqual(BatteryEstimate(seconds: 3599).detailedTitle, "0h 59m")
        XCTAssertEqual(BatteryEstimate(seconds: 3600).detailedTitle, "1h 0m")
        XCTAssertEqual(BatteryEstimate(seconds: 0).detailedTitle, "0h 0m")
    }

    func testChargingHidesTheItemAndStoppingChargingRestoresIt() {
        XCTAssertFalse(BatteryEstimate(seconds: -1, onExternalPower: true, isCharging: true).isVisible)
        XCTAssertTrue(BatteryEstimate(seconds: -1, onExternalPower: true, isCharging: false).isVisible)
        XCTAssertTrue(BatteryEstimate(seconds: 3600).isVisible)
    }
}
