import Foundation
import RevenueCat

@_exported import Core

// Platform-specific imports
#if os(iOS)
@_exported import AnalyticsPurchaseKit_iOS
#endif

/// Main AnalyticsPurchaseKit module that provides unified access to all functionality
/// 
/// Key classes available:
/// - AnalyticsPurchaseKit: Main configuration and setup
/// - Analytics: Core analytics tracking with event validation
/// - PaywallManager: Platform-specific paywall management
/// - EventVerb: Standardized action verbs for consistent event naming
/// - AnalyticsError: Comprehensive error handling for analytics operations
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
    ///   - userId: Optional user identifier to associate with all analytics and purchase providers
    /// - Throws: ConfigurationError if configuration fails
    func configureWithPlatformSupport(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        superwallAPIKey: String? = nil,
        environment: Environment = .production,
        userId: String? = nil
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
        #if canImport(SuperwallKit)
        try configureSuperwallFromConfig()
        #endif
        
        // Set userId for all providers if provided
        if let userId = userId {
            Analytics.shared.setUserId(userId)
            // Set userId for Superwall (iOS only)
            #if os(iOS)
            Superwall.shared.identify(userId: userId)
            #endif
            // Set userId for RevenueCat
            Purchases.shared.logIn(userId) { customerInfo, created, error in
                if let error = error {
                    print("[AnalyticsPurchaseKit] RevenueCat logIn error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Convenience method for quick configuration with minimal parameters
    /// Uses production environment by default and requires only essential keys
    /// - Parameters:
    ///   - posthogKey: PostHog API key
    ///   - mixpanelKey: Mixpanel API key  
    ///   - telemetryDeckAppID: TelemetryDeck app ID
    ///   - sentryDSN: Sentry DSN
    ///   - revenueCatAPIKey: RevenueCat API key
    ///   - userId: Optional user identifier to associate with all analytics and purchase providers
    /// - Throws: ConfigurationError if configuration fails
    func quickConfigure(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        userId: String? = nil
    ) throws {
        try configureWithPlatformSupport(
            posthogKey: posthogKey,
            mixpanelKey: mixpanelKey,
            telemetryDeckAppID: telemetryDeckAppID,
            sentryDSN: sentryDSN,
            revenueCatAPIKey: revenueCatAPIKey,
            superwallAPIKey: nil,
            environment: .production,
            userId: userId
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
    ///   - userId: Optional user identifier to associate with all analytics and purchase providers
    /// - Throws: ConfigurationError if configuration fails
    func configureDevelopment(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        superwallAPIKey: String? = nil,
        userId: String? = nil
    ) throws {
        try configureWithPlatformSupport(
            posthogKey: posthogKey,
            mixpanelKey: mixpanelKey,
            telemetryDeckAppID: telemetryDeckAppID,
            sentryDSN: sentryDSN,
            revenueCatAPIKey: revenueCatAPIKey,
            superwallAPIKey: superwallAPIKey,
            environment: .development,
            userId: userId
        )
    }
} 