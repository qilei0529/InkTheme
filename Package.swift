// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "InkTheme",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(name: "InkTheme", targets: ["InkTheme"]),
    ],
    targets: [
        .target(
            name: "InkTheme",
            swiftSettings: inkSwiftSettings
        ),
        .testTarget(
            name: "InkThemeTests",
            dependencies: ["InkTheme"],
            swiftSettings: inkSwiftSettings
        ),
    ]
)

/// Match the example app: Swift 5 language mode, MainActor by default, and member import visibility.
private let inkSwiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v5),
    .defaultIsolation(MainActor.self),
    .enableUpcomingFeature("MemberImportVisibility"),
]
