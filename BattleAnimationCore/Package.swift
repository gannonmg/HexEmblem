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
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0"),
        .package(path: "../GameCore"),
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
            dependencies: [
                "ScriptParser",
                "ImageUtilities",
                "BAModel",
                .product(name: "GameModels", package: "GameCore"),
            ]
        ),
        .executableTarget(
            name: "BAImportTool",
            dependencies: [
                "ImportTooling",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(
            name: "BAPlayback",
            dependencies: ["BAModel"],
            resources: [.copy("Resources/animations.bapack")]
        ),
        .testTarget(
            name: "BAPlaybackTests",
            dependencies: ["BAPlayback", "BAModel"]
        ),
    ]
)
