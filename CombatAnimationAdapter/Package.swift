// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombatAnimationAdapter",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CAAdapter",
            targets: ["CombatAnimationAdapter"]
        ),
    ],
    dependencies: [
        .package(path: "../BattleAnimationCore"),
        .package(path: "../CombatCore"),
        .package(path: "../GameCore"),
        .package(path: "../GameDebug"),
        .package(path: "../Utility"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CombatAnimationAdapter",
            dependencies: [
                .product(name: "BAPlayback", package: "BattleAnimationCore"),
                .product(name: "CCEvaluator", package: "CombatCore"),
                .product(name: "CombatModels", package: "CombatCore"),
                .product(name: "GameDebug", package: "GameDebug"),
                .product(name: "GameModels", package: "GameCore"),
                .product(name: "AnimationUtility", package: "Utility"),
                .product(name: "HECommon", package: "Utility"),
                .product(name: "SwiftUIUtility", package: "Utility"),
            ],
            resources: [.copy("Assets")],
        ),
        .testTarget(
            name: "CombatAnimationAdapterTests",
            dependencies: ["CombatAnimationAdapter"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
