// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BattleAnimationCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BAPlayback",
            targets: ["BAPlayback"]
        ),
        .executable(
            name: "BAImportTool",
            targets: ["BAImportTool"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "BAModel"),
        .target(
            name: "ImageUtilities",
            dependencies: ["BAModel"]
        ),
        .target(
            name: "ScriptParser",
            dependencies: ["BAModel"]
        ),
        .target(
            name: "ImportTooling",
            dependencies: ["ScriptParser", "ImageUtilities", "BAModel"]
        ),
        .executableTarget(
            name: "BAImportTool",
            dependencies: ["ImportTooling"]
        ),
        .target(
            name: "BAPlayback",
            dependencies: ["BAModel"],
            exclude: ["Resources/SourceAnimations"],
            resources: [.copy("Resources/ProcessedAnimations")]
        ),
        .testTarget(
            name: "BAPlaybackTests",
            dependencies: ["BAPlayback", "BAModel"]
        ),
    ]
)
