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
            name: "Banner",
            dependencies: [
                "AnalyticsManager",
                "DesignSystem",
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
                "Settings",
                "SurebetCalculator",
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
                "Banner",
                "DesignSystem",
                "MainMenu",
                "Onboarding",
                "Settings",
                "ReviewHandler",
                "Survey",
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
            name: "Survey",
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
            name: "SurebetCalculator",
            dependencies: [
                "Banner",
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
            name: "SurveyTests",
            dependencies: [
                "Survey",
            ],
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
                "Banner",
                "FeatureToggles",
                "ReviewHandler",
                "Survey",
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
