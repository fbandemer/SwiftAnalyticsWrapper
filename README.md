# Analytics Package

A unified analytics solution for iOS applications that integrates multiple tracking and analytics services including PostHog, Superwall, RevenueCat, and Sentry.

## Requirements

- iOS 17.0+
- Swift 5.10+

## Installation

Add this package to your iOS project using Swift Package Manager.

## Core Features

- Unified interface for multiple analytics providers
- Automatic event tracking
- User identification and attribute management
- Subscription tracking integration
- SwiftUI components for analytics-aware UI elements
- Crash reporting and monitoring

## Quick Start

### Initialize Analytics

```swift
import AnalyticsManager
import SwiftAnalyticsKitInterface

var analytics: AnalyticsClient = .default()
analytics.configure(
    AnalyticsConfiguration(
        loggerSubsystem: "com.example.app",
        loggerCategory: "analytics",
        superwallAPIKey: "your_superwall_id",
        posthogAPIKey: "your_posthog_key",
        revenueCatAPIKey: "your_revenuecat_id"
    ),
    .standard
)

analytics.setUserIdentity(
    AnalyticsUserIdentity(id: userID, email: "user@example.com")
)

var featureFlags: FeatureFlagClient = .default()
featureFlags.configure("your_posthog_key")

// Configure crash reporting separately when needed
let crashConfig = CrashConfiguration(
    dsn: "your_sentry_dsn",
    environment: "production"
)
var crashClient: CrashClient = .default()
crashClient.start(crashConfig)
```

Inject the observable manager into SwiftUI when you need environment access:

```swift
import Dependencies

struct RootView: View {
    @Dependency(\.analytics) var analytics

    var body: some View {
        Button("Track CTA") {
            analytics.performEvent(
                category: AppCategory.dashboard,
                object: "upgrade_cta",
                verb: .click
            ) {
                presentPaywall()
            }
        }
    }
}
```

### Track Events

```swift
import SwiftAnalyticsKitInterface
import AnalyticsManager

var analytics: AnalyticsClient = .default()

let event = try AnalyticsEvent(
    category: AppCategory.account_settings,
    object: "delete_account_button",
    verb: .click,
    properties: [
        "button_type": .string("destructive"),
        "plan": .string("pro")
    ]
)

analytics.track(event)
```

> Define your own enums that conform to `AnalyticsCategory` to describe feature areas (e.g. `enum AppCategory: String, AnalyticsCategory { case account_settings }`).

## Event Naming Conventions

All events follow the `category:object:verb` structure outlined in the Simple Event Naming Conventions for Product Analytics playbook:

1. **Category** – snake_case enum describing the product surface (`billing_portal`).
2. **Object** – snake_case noun for the specific element (`delete_account_button`).
3. **Verb** – present-tense value from `AnalyticsVerb` (`.click`, `.view`, `.submit`).

`AnalyticsNamingRules` validates every component and throws if casing or characters drift from the contract, ensuring consistent, queryable analytics data.

### Set User Attributes

```swift
analytics.setUserAttribute("attribute_name", .string("attribute_value"))
```

## UI Components

### Button Actions

Instead of shipping prebuilt SwiftUI buttons, the package exposes a `performEvent` helper so every app can design its own UI controls while still enforcing naming rules:

```swift
Button("Upgrade") {
    analytics.performEvent(
        category: AppCategory.dashboard,
        object: "upgrade_cta",
        verb: .click,
        attributes: ["cta_variant": .string("summer_campaign")]
    ) {
        // Your original action
        presentPaywall()
    }
}
```

## Advanced Features

### Increment Attributes

Increment numeric attributes:

```swift
analytics.incrementUserAttribute("count", 1.0)
```

### Subscription Status

Track subscription status:

```swift
analytics.setSubscriptionStatus(true, "premium_status")
```

### User Identification

Update user identification:

```swift
let identity = AnalyticsUserIdentity(
    id: "user123",
    email: "user@example.com",
    attributes: ["plan": .string("starter")]
)

analytics.setUserIdentity(identity)
```

### Feature Flags

Evaluate PostHog feature flags without leaving the analytics façade:

```swift
var featureFlags: FeatureFlagClient = .default()
featureFlags.configure("posthog_api_key")

if featureFlags.isFeatureFlagEnabled("paywall_v2") {
    let payload = featureFlags.featureFlagPayloadIfEnabled("paywall_v2")
    print(payload?.anyValue ?? "no payload")
}

if featureFlags.isFeatureFlagInVariant("onboarding_experiment", "treatment") {
    let payload = featureFlags.featureFlagPayload("onboarding_experiment", "treatment")
    // use variant-specific payload data
}
```

### Customer Center

Present RevenueCat's customer center without importing `RevenueCatUI` in your app target:

```swift
import Dependencies

struct SupportView: View {
    @Dependency(\.analytics) var analytics

    var body: some View {
        analytics.makeCustomerCenterView()
    }
}
```

## Platform Notes

- Superwall integration is available only on iOS builds. Pass `nil` for `superwallID` when targeting macOS; UI components continue to function by running their actions immediately.

## Dependencies

This package integrates with several third-party analytics providers:

- Superwall iOS
- Sentry Cocoa
- RevenueCat
- PostHog iOS

## Configuration

RevenueCat-specific helpers that are not part of the pure analytics surface are exposed as convenience extensions on `AnalyticsClient`.

### RevenueCat Attribution

Enable RevenueCat attribution tracking:

```swift
analytics.setRCAttributionConsent()
```

### Restore Purchases

Restore user purchases asynchronously:

```swift
do {
    let customerInfo = try await analytics.restorePurchases()
    // Handle restored purchases
} catch {
    // Handle errors
}
```

## Testing Utilities

`AnalyticsManagerTesting` ships mocks and sample categories so features can validate analytics logic without hitting live SDKs.

```swift
import AnalyticsManagerTesting

let mock = MockAnalyticsManager()
let analytics = mock.client
let event = try AnalyticsEvent(
    category: AnalyticsTestCategory.test_flow,
    object: "primary_cta",
    verb: .click
)

analytics.track(event)
XCTAssertEqual(mock.trackedEvents.first?.name, "test_flow:primary_cta:click")
```

## Best Practices

1. Initialize analytics early in your app's lifecycle
2. Use consistent event naming conventions
3. Include relevant context in event parameters
4. Handle errors appropriately
5. Consider privacy implications when tracking user data

## License

This package is available under the MIT license.
