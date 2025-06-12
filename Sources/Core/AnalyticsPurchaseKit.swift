import Foundation
import RevenueCat
import PostHog
import Mixpanel
import TelemetryClient
import Sentry

/// Core functionality shared across iOS and macOS platforms
public final class AnalyticsPurchaseKit {
    
    /// Shared instance for singleton access
    public static let shared = AnalyticsPurchaseKit()
    
    /// Configuration state
    private var isConfigured = false
    
    /// Environment configuration
    public enum Environment {
        case development
        case production
    }
    
    private init() {}
    
    /// Configure the AnalyticsPurchaseKit with all necessary API keys and settings
    /// - Parameters:
    ///   - posthogKey: PostHog API key for analytics and feature flags
    ///   - mixpanelKey: Mixpanel API key for product analytics
    ///   - telemetryDeckAppID: TelemetryDeck app ID for privacy-focused analytics
    ///   - sentryDSN: Sentry DSN for crash reporting
    ///   - revenueCatAPIKey: RevenueCat API key for purchase management
    ///   - superwallAPIKey: Superwall API key (iOS only, ignored on macOS)
    ///   - environment: Environment configuration (development/production)
    public func configure(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        superwallAPIKey: String? = nil,
        environment: Environment = .production
    ) {
        guard !isConfigured else {
            print("AnalyticsPurchaseKit: Already configured, ignoring subsequent configuration calls")
            return
        }
        
        // Configure PostHog
        configurePostHog(apiKey: posthogKey, environment: environment)
        
        // Configure Mixpanel
        configureMixpanel(apiKey: mixpanelKey, environment: environment)
        
        // Configure TelemetryDeck
        configureTelemetryDeck(appID: telemetryDeckAppID, environment: environment)
        
        // Configure Sentry
        configureSentry(dsn: sentryDSN, environment: environment)
        
        // Configure RevenueCat
        configureRevenueCat(apiKey: revenueCatAPIKey, environment: environment)
        
        // Platform-specific configuration will be handled by platform targets
        
        isConfigured = true
        print("AnalyticsPurchaseKit: Successfully configured for \(environment)")
    }
    
    // MARK: - Private Configuration Methods
    
    private func configurePostHog(apiKey: String, environment: Environment) {
        let config = PostHogConfig(apiKey: apiKey)
        config.debug = environment == .development
        PostHogSDK.shared.setup(config)
    }
    
    private func configureMixpanel(apiKey: String, environment: Environment) {
        let mixpanel = Mixpanel.initialize(token: apiKey)
        if environment == .development {
            mixpanel.loggingEnabled = true
        }
    }
    
    private func configureTelemetryDeck(appID: String, environment: Environment) {
        let configuration = TelemetryManagerConfiguration(appID: appID)
        configuration.analyticsDisabled = environment == .development
        TelemetryManager.initialize(with: configuration)
    }
    
    private func configureSentry(dsn: String, environment: Environment) {
        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = environment == .development ? "development" : "production"
            options.debug = environment == .development
        }
    }
    
    private func configureRevenueCat(apiKey: String, environment: Environment) {
        if environment == .development {
            Purchases.logLevel = .debug
        }
        Purchases.configure(withAPIKey: apiKey)
    }
} 