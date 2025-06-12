# SwiftAnalyticsWrapper

A unified analytics solution for iOS applications that integrates multiple tracking and analytics services including Mixpanel, TelemetryDeck, PostHog, Superwall, RevenueCat, and Sentry.

## Requirements

- iOS 17.0+
- Swift 5.10+

## Installation

Add this package to your iOS project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftAnalyticsWrapper.git", from: "1.0.0")
]
```

## Core Features

- Unified interface for multiple analytics providers
- Automatic event tracking with structured events
- User identification and attribute management
- Subscription tracking integration
- SwiftUI components for analytics-aware UI elements
- Crash reporting and monitoring
- Feature flag support via PostHog

## Quick Start

### Initialize Analytics

Using the modern configuration approach:

```swift
let config = AnalyticsConfiguration(
    userID: currentUserID,
    logger: logger,
    superwallID: "your_superwall_id",
    posthogAPIKey: "your_posthog_key", 
    telemetryID: "your_telemetry_id",
    mixpanelID: "your_mixpanel_id",
    sentryDSN: "your_sentry_dsn",
    revenueCatID: "your_revenuecat_id"
)

Analytics.shared.initialize(with: config)
```

### Track Events

Using the modern structured approach:

```swift
// Using AnalyticsEvent
let event = AnalyticsEvent(
    name: "purchase_completed",
    parameters: ["product_id": "premium_123", "price": 9.99],
    value: 9.99
)
Analytics.shared.track(event: event)

// Or using the convenience method
Analytics.shared.track(
    event: "screen_viewed",
    params: ["screen_name": "settings"]
)
```

### Set User Attributes

```swift
Analytics.shared.setUserAttribute(key: "subscription_level", value: "premium")
```

## UI Components

### EventButton

A SwiftUI button that automatically tracks user interactions:

```swift
EventButton(
    category: "settings",
    object: "dark_mode",
    verb: .tap,
    params: ["previous_state": isDarkMode]
) {
    isDarkMode.toggle()
} label: {
    Text("Toggle Dark Mode")
}
```

### NavigationButton

A specialized button for navigation actions with built-in analytics tracking:

```swift
NavigationButton(
    category: "main",
    object: "settings",
    verb: .navigate,
    rowAlignment: .center
) {
    showSettings = true
} label: {
    Text("Settings")
}
```

## Feature Flags

Check if a feature is enabled through PostHog:

```swift
if FeatureFlag.isEnabled("premium_features") {
    // Show premium features
}

// Or with payload
let (isEnabled, payload) = FeatureFlag.isEnabledWithPayload("experiment_1")
if isEnabled {
    // Use payload data for the experiment
}
```

## Advanced Features

### Time Events

Track the duration of events:

```swift
Analytics.shared.time(event: "content_loading")
// ... content loads
Analytics.shared.track(event: "content_loading", params: ["success": true])
```

### Increment Attributes

Increment numeric attributes:

```swift
Analytics.shared.incrementAttribute(key: "articles_read", value: 1.0)
```

### Subscription Status

Track subscription status:

```swift
Analytics.shared.setSubscriptionStatus(active: true, key: "premium_status")
```

### Screen Capture

Enable screen capture for analytics:

```swift
.modifier(ScreenCaptureModifier())
```

## Dependencies

This package integrates with several third-party analytics providers:

- TelemetryDeck SwiftClient (from 1.5.0)
- Mixpanel Swift (from 2.11.1)
- Superwall iOS (from 4.0.0)
- Sentry Cocoa (from 8.36.0)
- RevenueCat (from 5.2.0)
- PostHog iOS (from 3.0.0)

## License

This package is available under the MIT license.
