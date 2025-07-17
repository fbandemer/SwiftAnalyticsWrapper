// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [.iOS(.v26)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Analytics",
            targets: ["Analytics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/TelemetryDeck/SwiftClient", from: "1.5.0"),
        .package(url: "https://github.com/mixpanel/mixpanel-swift", branch: "master"),
        .package(url: "https://github.com/superwall-me/Superwall-iOS", .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/getsentry/sentry-cocoa", from: "8.36.0"),
        //        .package(url: "https://github.com/getsentry/sentry-cocoa", branch: "Sentry-Dynamic"),
        .package(url: "https://github.com/RevenueCat/purchases-ios.git", from: "5.2.0"),
        .package(url: "https://github.com/PostHog/posthog-ios.git", from: "3.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Analytics",

            dependencies: [
//                "TelemetryClient",
                .product(name: "TelemetryClient", package: "SwiftClient"),
                .product(name: "Mixpanel", package: "mixpanel-swift"),
//                "Mixpanel",
                .product(name: "SuperwallKit", package: "Superwall-iOS"),
//                "SuperwallKit",
                    .product(name: "Sentry-Dynamic", package: "sentry-cocoa"),
                .product(name: "RevenueCat", package: "purchases-ios"),
                .product(name: "RevenueCatUI", package: "purchases-ios"),
                .product(name: "PostHog", package: "posthog-ios"),
//                "RevenueCat"
            ])

    ]
)
