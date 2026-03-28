// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FFormkit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "FFormkit",
            targets: ["FFormkit"]
        ),
    ],
    targets: [
        .target(
            name: "FFormkit",
            path: "Sources/FFormkit"
        ),
        .testTarget(
            name: "FFormkitTests",
            dependencies: ["FFormkit"],
            path: "Tests/FFormkitTests"
        ),
    ]
)
