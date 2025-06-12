// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnalyticsPurchaseKit",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AnalyticsPurchaseKit",
            targets: ["AnalyticsPurchaseKit"]),
        .library(
            name: "AnalyticsPurchaseKit-iOS",
            targets: ["AnalyticsPurchaseKit-iOS"]),
        .library(
            name: "AnalyticsPurchaseKit-macOS",
            targets: ["AnalyticsPurchaseKit-macOS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "4.25.0"),
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "4.0.0"),
        .package(url: "https://github.com/TelemetryDeck/SwiftClient", from: "1.5.0"),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.9.0"),
        .package(url: "https://github.com/superwall/Superwall-iOS", from: "3.2.0"),
    ],
    targets: [
        // Core shared functionality
        .target(
            name: "Core",
            dependencies: [
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "PostHog", package: "posthog-ios"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "TelemetryClient", package: "SwiftClient"),
                .product(name: "Sentry", package: "sentry-cocoa"),
            ],
            path: "Sources/Core"
        ),
        
        // iOS-specific target
        .target(
            name: "AnalyticsPurchaseKit-iOS",
            dependencies: [
                "Core",
                .product(name: "SuperwallKit", package: "Superwall-iOS"),
            ],
            path: "Sources/iOS"
        ),
        
        // macOS-specific target
        .target(
            name: "AnalyticsPurchaseKit-macOS",
            dependencies: [
                "Core",
            ],
            path: "Sources/macOS"
        ),
        
        // Main target that conditionally includes platform-specific code
        .target(
            name: "AnalyticsPurchaseKit",
            dependencies: [
                "Core",
                .target(name: "AnalyticsPurchaseKit-iOS", condition: .when(platforms: [.iOS])),
                .target(name: "AnalyticsPurchaseKit-macOS", condition: .when(platforms: [.macOS])),
            ],
            path: "Sources/AnalyticsPurchaseKit"
        ),
        
        // UI Components
        .target(
            name: "UI",
            dependencies: [
                "Core",
            ],
            path: "Sources/UI"
        ),
        
        // Swift Macros
        .target(
            name: "Macros",
            dependencies: [
                "Core",
            ],
            path: "Sources/Macros"
        ),
        
        // Tests
        .testTarget(
            name: "AnalyticsPurchaseKitTests",
            dependencies: [
                "AnalyticsPurchaseKit",
                "Core",
            ],
            path: "Tests"
        ),
    ]
)
