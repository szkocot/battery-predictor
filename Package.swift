// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BatteryPredictor",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "BatteryPredictor", targets: ["BatteryPredictor"])],
    targets: [
        .target(name: "BatteryCore"),
        .executableTarget(name: "BatteryPredictor", dependencies: ["BatteryCore"]),
        .testTarget(name: "BatteryCoreTests", dependencies: ["BatteryCore"])
    ]
)
