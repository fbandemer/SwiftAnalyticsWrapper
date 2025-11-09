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
import AnalyticsManagerInterface

let analytics = DefaultAnalyticsManager.shared
analytics.initialize(
    for: userID,
    with: logger,
    superwallID: "your_superwall_id",
    posthogAPIKey: "your_posthog_key",
    sentry: "your_sentry_dsn",
    revenueCatID: "your_revenuecat_id",
    userDefault: .standard
)
```

Inject the observable manager into SwiftUI when you need environment access:

```swift
@State private var analytics = DefaultAnalyticsManager.shared

var body: some View {
    RootView()
        .environment(analytics)
}
```

### Track Events

```swift
import AnalyticsManagerInterface

let event = try AnalyticsEvent(
    category: AppCategory.account_settings,
    object: "delete_account_button",
    verb: .click,
    properties: [
        "button_type": .string("destructive"),
        "plan": .string("pro")
    ]
)

DefaultAnalyticsManager.shared.track(event)
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
DefaultAnalyticsManager.shared.setUserAttribute(
    "attribute_name",
    value: .string("attribute_value")
)
```

## UI Components

### Button Actions

Instead of shipping prebuilt SwiftUI buttons, the package exposes a `performEvent` helper so every app can design its own UI controls while still enforcing naming rules:

```swift
Button("Upgrade") {
    DefaultAnalyticsManager.shared.performEvent(
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

### Time Events

Track the duration of events:

```swift
DefaultAnalyticsManager.shared.time(event: "event_name")
```

### Increment Attributes

Increment numeric attributes:

```swift
DefaultAnalyticsManager.shared.incrementUserAttribute("count", by: 1.0)
```

### Subscription Status

Track subscription status:

```swift
DefaultAnalyticsManager.shared.setSubscriptionStatus(isActive: true, key: "premium_status")
```

### User Identification

Update user identification:

```swift
let identity = AnalyticsUserIdentity(
    id: "user123",
    email: "user@example.com",
    attributes: ["plan": .string("starter")]
)

DefaultAnalyticsManager.shared.setUserIdentity(identity)
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

### RevenueCat Attribution

Enable RevenueCat attribution tracking:

```swift
DefaultAnalyticsManager.shared.setRCAttributionConsent()
```

### Restore Purchases

Restore user purchases asynchronously:

```swift
do {
    let customerInfo = try await DefaultAnalyticsManager.shared.restorePurchases()
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
let event = try AnalyticsEvent(
    category: AnalyticsTestCategory.test_flow,
    object: "primary_cta",
    verb: .click
)

mock.track(event)
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
