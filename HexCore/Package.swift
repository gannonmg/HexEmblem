// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HexCore",
    platforms: [.macOS(.v15), .iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HexCore",
            targets: ["HexCore"]
        ),
        .library(
            name: "HexMapUI",
            targets: ["HexMapUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HexCore",
            dependencies: [
                .product(name: "HeapModule", package: "swift-collections")
            ]
        ),
        .target(
            name: "HexMapUI",
            dependencies: ["HexCore"],
        ),
        .testTarget(
            name: "HexCoreTests",
            dependencies: ["HexCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
