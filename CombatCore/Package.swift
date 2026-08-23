// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CombatCore",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "CCEvaluator",
            targets: ["CCEvaluator"]
        ),
        .library(
            name: "CombatModels",
            targets: ["CombatModels"]
        ),
    ],
    dependencies: [
        .package(path: "../GameCore")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "CombatModels",
            dependencies: [
                .product(name: "GameModels", package: "GameCore"),
                .product(name: "GameRules", package: "GameCore"),
            ]
        ),
        .target(
            name: "CombatCore",
            dependencies: [
                "CombatModels",
                .product(name: "GameModels", package: "GameCore"),
            ]
        ),
        .target(
            name: "CCEvaluator",
            dependencies: [
                "CombatCore",
                "CombatModels",
            ]
        ),
        .testTarget(
            name: "CombatCoreTests",
            dependencies: ["CombatCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
