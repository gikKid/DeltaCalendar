// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "DeltaCalendar",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "DeltaCalendar", targets: ["DeltaCalendar"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.1")
    ],
    targets: [
        .target(name: "DeltaCalendar", dependencies: ["SnapKit"]),
        .testTarget(name: "DeltaCalendarTests", dependencies: ["DeltaCalendar"])
    ]
)
