import Foundation

// Re-export Core functionality
@_exported import Core

// Platform-specific imports
#if os(iOS)
@_exported import AnalyticsPurchaseKit_iOS
#elseif os(macOS)
@_exported import AnalyticsPurchaseKit_macOS
#endif

/// Main AnalyticsPurchaseKit module that provides unified access to all functionality
public extension AnalyticsPurchaseKit {
    
    /// Enhanced configure method that handles platform-specific setup
    /// - Parameters:
    ///   - posthogKey: PostHog API key for analytics and feature flags
    ///   - mixpanelKey: Mixpanel API key for product analytics
    ///   - telemetryDeckAppID: TelemetryDeck app ID for privacy-focused analytics
    ///   - sentryDSN: Sentry DSN for crash reporting
    ///   - revenueCatAPIKey: RevenueCat API key for purchase management
    ///   - superwallAPIKey: Superwall API key (iOS only, ignored on macOS)
    ///   - environment: Environment configuration (development/production)
    func configureWithPlatformSupport(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        superwallAPIKey: String? = nil,
        environment: Environment = .production
    ) {
        // Call the base configuration
        configure(
            posthogKey: posthogKey,
            mixpanelKey: mixpanelKey,
            telemetryDeckAppID: telemetryDeckAppID,
            sentryDSN: sentryDSN,
            revenueCatAPIKey: revenueCatAPIKey,
            superwallAPIKey: superwallAPIKey,
            environment: environment
        )
        
        // Configure platform-specific features
        if let superwallAPIKey = superwallAPIKey {
            configureSuperwall(apiKey: superwallAPIKey, environment: environment)
        }
    }
} 