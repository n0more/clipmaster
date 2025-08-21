// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "ClipMaster",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/soffes/HotKey.git", from: "0.1.3"),
        // .package(url: "https://github.com/sparkle-project/Sparkle.git", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "ClipMaster",
            dependencies: [
                "HotKey",
                // .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources/ClipMaster"
        )
    ]
)
