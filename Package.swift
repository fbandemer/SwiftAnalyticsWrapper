// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftAnalyticsWrapper",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Analytics",
            targets: ["Analytics"]),
        .library(
            name: "AnalyticsCore",
            targets: ["AnalyticsCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/TelemetryDeck/SwiftClient", from: "1.5.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", from: "2.11.1"),
        .package(url: "https://github.com/superwall-me/Superwall-iOS", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.36.0"),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.2.0"),
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "AnalyticsCore",
            dependencies: []),
        .target(
            name: "Analytics",
            dependencies: [
                "AnalyticsCore",
                .product(name: "TelemetryClient", package: "SwiftClient"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
                .product(name: "SuperwallKit", package: "Superwall-iOS"),
                .product(name: "Sentry-Dynamic", package: "sentry-cocoa"),
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "RevenueCatUI", package: "purchases-ios"),
                .product(name: "PostHog", package: "posthog-ios"),
            ]),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: ["Analytics"]),
    ]
)
