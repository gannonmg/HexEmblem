// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HexCore",
    platforms: [.macOS(.v26), .iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HexCore",
            targets: ["HexCore"]
        ),
        .library(
            name: "HexGridUI",
            targets: ["HexGridUI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HexCore",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "HeapModule", package: "swift-collections"),
            ]
        ),
        .target(
            name: "HexGridUI",
            dependencies: ["HexCore"],
        ),
        .testTarget(
            name: "HexCoreTests",
            dependencies: ["HexCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

//.executable(
//    name: "HexGridExampleApp",
//    targets: ["HexGridExampleApp"]
//),
//.executableTarget(
//    name: "HexGridExampleApp",
//    dependencies: ["HexGridUI"],
//),
//.library(
//    name: "HexMapUI",
//    targets: ["HexMapUI"]
//),
//.target(
//    name: "HexMapUI",
//    dependencies: ["HexCore"],
//),
