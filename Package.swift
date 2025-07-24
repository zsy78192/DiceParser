// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiceParser",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        .executable(
            name: "DiceParser",
            targets: ["DiceParser"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "DiceParser",
            dependencies: []),
        .testTarget(
            name: "DiceParserTests",
            dependencies: ["DiceParser"]),
    ]
)