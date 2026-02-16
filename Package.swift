// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AIAnalyzer",
    platforms: [
        .iOS(.v17)
    ],

    products: [
        .library(
            name: "AIAnalyzer",
            targets: ["AIAnalyzer"]
        ),
    ],

    targets: [
        .target(
            name: "AIAnalyzer",
            resources: [
                .process("Resources")
            ],
        ),
        .testTarget(
            name: "AIAnalyzerTests",
            dependencies: ["AIAnalyzer"]
        ),
    ]
)
