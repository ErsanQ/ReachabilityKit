// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReachabilityKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ReachabilityKit",
            targets: ["ReachabilityKit"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ReachabilityKit",
            dependencies: [],
            path: "Sources/ReachabilityKit"),
        .testTarget(
            name: "ReachabilityKitTests",
            dependencies: ["ReachabilityKit"],
            path: "Tests/ReachabilityKitTests"),
    ]
)
