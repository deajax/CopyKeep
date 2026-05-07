// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CopyKeep",
    platforms: [
        .macOS(.v14),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift", from: "6.29.0"),
        .package(url: "https://github.com/sindresorhus/KeyboardShortcuts", from: "1.17.0"),
        .package(url: "https://github.com/sindresorhus/LaunchAtLogin", from: "5.0.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.7.0"),
    ],
    targets: [
        .executableTarget(
            name: "CopyKeep",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "KeyboardShortcuts", package: "KeyboardShortcuts"),
                .product(name: "LaunchAtLogin", package: "LaunchAtLogin"),
                .product(name: "Sparkle", package: "Sparkle"),
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CopyKeepTests",
            dependencies: ["CopyKeep"],
            path: "Tests/CopyKeepTests"
        ),
    ]
)
