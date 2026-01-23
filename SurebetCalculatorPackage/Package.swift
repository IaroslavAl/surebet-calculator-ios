// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SurebetCalculatorPackage",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Root",
            targets: ["Root"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/appmetrica/appmetrica-sdk-ios.git",
            .upToNextMinor(from: "5.11.0")
        ),
        .package(
            url: "https://github.com/realm/SwiftLint.git",
            .upToNextMinor(from: "0.59.1")
        ),
        .package(
            url: "https://github.com/SDWebImage/SDWebImageSwiftUI.git",
            .upToNextMinor(from: "3.1.3")
        ),
    ],
    targets: [
        .target(
            name: "AnalyticsManager",
            dependencies: [
                .product(
                    name: "AppMetricaCore",
                    package: "appmetrica-sdk-ios"
                )
            ],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .target(
            name: "Banner",
            dependencies: [
                "AnalyticsManager",
                .product(
                    name: "SDWebImageSwiftUI",
                    package: "SDWebImageSwiftUI"
                ),
            ],
            resources: [.process("Resources/Assets.xcassets")],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .target(
            name: "Onboarding",
            resources: [.process("Resources")],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .target(
            name: "ReviewHandler",
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .target(
            name: "Root",
            dependencies: [
                "AnalyticsManager",
                "Banner",
                "Onboarding",
                "ReviewHandler",
                "SurebetCalculator",
                .product(
                    name: "AppMetricaCore",
                    package: "appmetrica-sdk-ios"
                )
            ],
            resources: [.process("Resources")],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .target(
            name: "SurebetCalculator",
            dependencies: [
                "Banner",
            ],
            resources: [.process("Resources")],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "OnboardingTests",
            dependencies: ["Onboarding"],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "SurebetCalculatorTests",
            dependencies: ["SurebetCalculator"],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "AnalyticsManagerTests",
            dependencies: ["AnalyticsManager"],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "BannerTests",
            dependencies: ["Banner"],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "ReviewHandlerTests",
            dependencies: ["ReviewHandler"],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "RootTests",
            dependencies: [
                "Root",
                "AnalyticsManager",
                "Banner",
                "ReviewHandler"
            ],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
    ]
)
