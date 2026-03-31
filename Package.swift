// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ReachabilityKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1)
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
    ]
)
