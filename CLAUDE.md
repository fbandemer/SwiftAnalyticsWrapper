# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Test
```bash
# Build the package
swift build

# Run tests
swift test

# Clean build
swift package clean

# Resolve dependencies
swift package resolve

# Open in Xcode (recommended for iOS development)
open Package.swift
```

### Development Workflow
Since this is an iOS package targeting iOS 26+, development is typically done in Xcode. The package uses Swift Package Manager (SPM) with Swift Tools Version 6.2.

## Architecture Overview

SwiftAnalyticsWrapper is a unified analytics abstraction layer that integrates multiple third-party services into a single, consistent API:

### Core Services Integrated
- **Analytics**: Mixpanel, PostHog, TelemetryDeck
- **Payments**: RevenueCat (in-app purchases)
- **Paywalls**: Superwall (paywall management)
- **Crash Reporting**: Sentry
- **Feature Flags**: PostHog

### Key Architectural Patterns

1. **Singleton Facade**: `Analytics.shared` is the single entry point for all operations
2. **Conditional Initialization**: Services are only activated if their API keys are provided
3. **Cross-Service Integration**: RevenueCat and Superwall are bridged through `RCPurchaseController`
4. **Event Broadcasting**: Single `track()` call sends events to all active services

### Important Classes and Their Roles

- `Analytics.swift`: Main facade class coordinating all services
- `SuperwallService.swift`: Delegate that tracks Superwall events across analytics services
- `RCPurchaseController.swift`: Bridges RevenueCat purchases with Superwall paywalls
- `FeatureFlag.swift`: PostHog feature flag interface
- `CrashManager.swift`: Sentry crash reporting wrapper

### Event Naming Convention
Events follow the pattern: `category:object_verb`
Example: `onboarding:signup_button_click`

### SwiftUI Components
The package provides analytics-enabled UI components:
- `EventButton`: Automatically tracks button clicks
- `NavigationButton`: Navigation tracking
- `SimpleEventButton`: Simplified event tracking
- `ScreenCaptureModifier`: Screen capture functionality

### Service Configuration Notes
- PostHog and Mixpanel use EU servers for privacy compliance
- Debug logging is enabled in DEBUG builds
- User attributes are stored in UserDefaults and synchronized across services
- Mixpanel's distinct ID is shared with RevenueCat for attribution

## Testing Approach
Tests use XCTest framework. Currently minimal test coverage exists. When adding features:
1. Add corresponding tests in `Tests/AnalyticsTests/`
2. Test both individual service integration and cross-service coordination
3. Mock external services when possible

## Adding New Analytics Services
1. Add the dependency to `Package.swift`
2. Create an integration file (like `RevenueCatIntegration.swift`) if needed
3. Add initialization in `Analytics.initialize()`
4. Add service-specific boolean flag (e.g., `useNewService`)
5. Integrate into relevant methods (`track`, `setUserID`, etc.)
6. Update README.md with usage examples