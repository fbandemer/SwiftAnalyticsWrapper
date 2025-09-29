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
Analytics.shared.initialize(
    for: userID,
    with: logger,
    superwallID: "your_superwall_id",
    posthogAPIKey: "your_posthog_key",
    sentry: "your_sentry_dsn",
    revenueCatID: "your_revenuecat_id",
    userDefault: .standard
)
```

### Track Events

```swift
Analytics.shared.track(
    event: "event_name",
    floatValue: optionalValue,
    params: ["key": "value"]
)
```

### Set User Attributes

```swift
Analytics.shared.setUserAttributes(key: "attribute_name", value: "attribute_value")
```

## UI Components

### EventButton

A SwiftUI button that automatically tracks user interactions:

```swift
EventButton(
    category: "screen_name",
    object: "button_name",
    verb: .tap,
    params: ["custom_param": "value"]
) {
    // Action to perform
} label: {
    Text("Click Me")
}
```

### NavigationButton

A specialized button for navigation actions with built-in analytics tracking:

```swift
NavigationButton(
    category: "screen_name",
    object: "navigation_item",
    verb: .navigate,
    rowAlignment: .center
) {
    // Navigation action
} label: {
    Text("Navigate to Settings")
}
```

## Advanced Features

### Time Events

Track the duration of events:

```swift
Analytics.shared.time(event: "event_name")
```

### Increment Attributes

Increment numeric attributes:

```swift
Analytics.shared.incrementAttribute(key: "count", value: 1.0)
```

### Subscription Status

Track subscription status:

```swift
Analytics.shared.setSubscriptionStatus(active: true, key: "premium_status")
```

### User Identification

Update user identification:

```swift
Analytics.shared.setUserID(userID: "user123")
```

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
Analytics.shared.setRCAttributionConsent()
```

### Restore Purchases

Restore user purchases asynchronously:

```swift
do {
    let customerInfo = try await Analytics.shared.restorePurchases()
    // Handle restored purchases
} catch {
    // Handle errors
}
```

## Best Practices

1. Initialize analytics early in your app's lifecycle
2. Use consistent event naming conventions
3. Include relevant context in event parameters
4. Handle errors appropriately
5. Consider privacy implications when tracking user data

## License

This package is available under the MIT license.
