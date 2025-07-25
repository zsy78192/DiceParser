// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DiceParser",
    platforms: [.macOS(.v10_15), .iOS(.v13)],
    products: [
        // 将 DiceParser 定义为一个库，以便其他项目可以导入和使用它
        .library(
            name: "DiceParser",
            targets: ["DiceParser"]),
        // 如果您仍然需要一个可执行文件用于测试或命令行工具，可以保留此项
        .executable(
            name: "DiceParserCLI", // 更改可执行文件的名称以避免与库名称冲突
            targets: ["DiceParserCLI"])
    ],
    dependencies: [],
    targets: [
        // DiceParser 库的目标
        .target(
            name: "DiceParser",
            dependencies: []),
        // DiceParser 命令行工具的可执行目标 (如果需要)
        // 您需要创建一个单独的源文件 (例如 main.swift) 在 DiceParserCLI 目录下
        .executableTarget(
            name: "DiceParserCLI",
            dependencies: ["DiceParser"]), // DiceParserCLI 依赖于 DiceParser 库
        // 测试目标
        .testTarget(
            name: "DiceParserTests",
            dependencies: ["DiceParser"]),
    ]
)