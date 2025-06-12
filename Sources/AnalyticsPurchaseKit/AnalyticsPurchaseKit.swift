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
    
    /// Enhanced configure method that handles platform-specific setup automatically
    /// This is the recommended configuration method that handles all platform-specific setup
    /// - Parameters:
    ///   - posthogKey: PostHog API key for analytics and feature flags
    ///   - mixpanelKey: Mixpanel API key for product analytics
    ///   - telemetryDeckAppID: TelemetryDeck app ID for privacy-focused analytics
    ///   - sentryDSN: Sentry DSN for crash reporting
    ///   - revenueCatAPIKey: RevenueCat API key for purchase management
    ///   - superwallAPIKey: Superwall API key (iOS only, ignored on macOS)
    ///   - environment: Environment configuration (development/production)
    /// - Throws: ConfigurationError if configuration fails
    func configureWithPlatformSupport(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        superwallAPIKey: String? = nil,
        environment: Environment = .production
    ) throws {
        // Call the base configuration
        try configure(
            posthogKey: posthogKey,
            mixpanelKey: mixpanelKey,
            telemetryDeckAppID: telemetryDeckAppID,
            sentryDSN: sentryDSN,
            revenueCatAPIKey: revenueCatAPIKey,
            superwallAPIKey: superwallAPIKey,
            environment: environment
        )
        
        // Configure platform-specific features automatically
        try configureSuperwallFromConfig()
    }
    
    /// Convenience method for quick configuration with minimal parameters
    /// Uses production environment by default and requires only essential keys
    /// - Parameters:
    ///   - posthogKey: PostHog API key
    ///   - mixpanelKey: Mixpanel API key  
    ///   - telemetryDeckAppID: TelemetryDeck app ID
    ///   - sentryDSN: Sentry DSN
    ///   - revenueCatAPIKey: RevenueCat API key
    /// - Throws: ConfigurationError if configuration fails
    func quickConfigure(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String
    ) throws {
        try configureWithPlatformSupport(
            posthogKey: posthogKey,
            mixpanelKey: mixpanelKey,
            telemetryDeckAppID: telemetryDeckAppID,
            sentryDSN: sentryDSN,
            revenueCatAPIKey: revenueCatAPIKey,
            superwallAPIKey: nil,
            environment: .production
        )
    }
    
    /// Development-specific configuration with debug settings enabled
    /// - Parameters:
    ///   - posthogKey: PostHog API key
    ///   - mixpanelKey: Mixpanel API key
    ///   - telemetryDeckAppID: TelemetryDeck app ID
    ///   - sentryDSN: Sentry DSN
    ///   - revenueCatAPIKey: RevenueCat API key
    ///   - superwallAPIKey: Optional Superwall API key
    /// - Throws: ConfigurationError if configuration fails
    func configureDevelopment(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        superwallAPIKey: String? = nil
    ) throws {
        try configureWithPlatformSupport(
            posthogKey: posthogKey,
            mixpanelKey: mixpanelKey,
            telemetryDeckAppID: telemetryDeckAppID,
            sentryDSN: sentryDSN,
            revenueCatAPIKey: revenueCatAPIKey,
            superwallAPIKey: superwallAPIKey,
            environment: .development
        )
    }
} 