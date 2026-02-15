// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SurebetCalculatorPackage",
    defaultLocalization: "en",
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
            .upToNextMinor(from: "6.0.0")
        ),
        .package(
            url: "https://github.com/realm/SwiftLint.git",
            .upToNextMinor(from: "0.63.2")
        ),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources")],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
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
            name: "Onboarding",
            dependencies: [
                "DesignSystem",
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
            name: "ReviewHandler",
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .target(
            name: "FeatureToggles",
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .target(
            name: "MainMenu",
            dependencies: [
                "DesignSystem",
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
            name: "Settings",
            dependencies: [
                "DesignSystem",
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
            name: "Root",
            dependencies: [
                "AnalyticsManager",
                "DesignSystem",
                "MainMenu",
                "Onboarding",
                "Settings",
                "ReviewHandler",
                "FeatureToggles",
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
                "DesignSystem",
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
            dependencies: [
                "Onboarding",
            ],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: [
                "Settings",
            ],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                )
            ]
        ),
        .testTarget(
            name: "SurebetCalculatorTests",
            dependencies: [
                "SurebetCalculator",
            ],
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
            name: "FeatureTogglesTests",
            dependencies: [
                "FeatureToggles",
            ],
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
                "FeatureToggles",
                "ReviewHandler",
                "SurebetCalculator"
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
