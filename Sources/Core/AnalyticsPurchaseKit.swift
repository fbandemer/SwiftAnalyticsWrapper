import Foundation
import RevenueCat
import PostHog
import Mixpanel
import TelemetryClient
import Sentry
import OSLog

/// Core functionality shared across iOS and macOS platforms
public final class AnalyticsPurchaseKit {
    
    /// Shared instance for singleton access
    public static let shared = AnalyticsPurchaseKit()
    
    /// Configuration state
    private var isConfigured = false
    
    /// Logger for debug output
    private let logger = Logger(subsystem: "com.analyticspurchasekit", category: "Configuration")
    
    /// Environment configuration
    public enum Environment: String, CaseIterable {
        case development = "development"
        case production = "production"
        
        public var isDebug: Bool {
            return self == .development
        }
    }
    
    /// Configuration errors
    public enum ConfigurationError: Error, LocalizedError {
        case alreadyConfigured
        case invalidAPIKey(service: String)
        case missingRequiredKey(service: String)
        case configurationFailed(service: String, reason: String)
        
        public var errorDescription: String? {
            switch self {
            case .alreadyConfigured:
                return "AnalyticsPurchaseKit has already been configured. Multiple configuration calls are not allowed."
            case .invalidAPIKey(let service):
                return "Invalid API key provided for \(service). Please check your configuration."
            case .missingRequiredKey(let service):
                return "Missing required API key for \(service)."
            case .configurationFailed(let service, let reason):
                return "Failed to configure \(service): \(reason)"
            }
        }
    }
    
    /// Secure storage for API keys (in-memory only)
    internal struct SecureConfiguration {
        let posthogKey: String
        let mixpanelKey: String
        let telemetryDeckAppID: String
        let sentryDSN: String
        let revenueCatAPIKey: String
        let superwallAPIKey: String?
        let environment: Environment
        
        /// Validate all API keys
        func validate() throws {
            try validateKey(posthogKey, service: "PostHog")
            try validateKey(mixpanelKey, service: "Mixpanel")
            try validateKey(telemetryDeckAppID, service: "TelemetryDeck")
            try validateKey(sentryDSN, service: "Sentry")
            try validateKey(revenueCatAPIKey, service: "RevenueCat")
            
            // Superwall is optional
            if let superwallKey = superwallAPIKey {
                try validateKey(superwallKey, service: "Superwall")
            }
        }
        
        private func validateKey(_ key: String, service: String) throws {
            guard !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ConfigurationError.missingRequiredKey(service: service)
            }
            
            // Basic validation - keys should be at least 10 characters
            guard key.count >= 10 else {
                throw ConfigurationError.invalidAPIKey(service: service)
            }
            
            // Additional service-specific validation
            switch service {
            case "Sentry":
                // Sentry DSN should start with https://
                guard key.hasPrefix("https://") else {
                    throw ConfigurationError.invalidAPIKey(service: service)
                }
            case "TelemetryDeck":
                // TelemetryDeck app ID should be UUID format
                guard UUID(uuidString: key) != nil else {
                    throw ConfigurationError.invalidAPIKey(service: service)
                }
            default:
                break
            }
        }
    }
    
    /// Current configuration (nil if not configured)
    private var configuration: SecureConfiguration?
    
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
    /// - Throws: ConfigurationError if configuration fails
    public func configure(
        posthogKey: String,
        mixpanelKey: String,
        telemetryDeckAppID: String,
        sentryDSN: String,
        revenueCatAPIKey: String,
        superwallAPIKey: String? = nil,
        environment: Environment = .production
    ) throws {
        guard !isConfigured else {
            logger.error("Attempted to configure AnalyticsPurchaseKit multiple times")
            throw ConfigurationError.alreadyConfigured
        }
        
        logger.info("Starting AnalyticsPurchaseKit configuration for \(environment.rawValue) environment")
        
        // Create and validate configuration
        let config = SecureConfiguration(
            posthogKey: posthogKey,
            mixpanelKey: mixpanelKey,
            telemetryDeckAppID: telemetryDeckAppID,
            sentryDSN: sentryDSN,
            revenueCatAPIKey: revenueCatAPIKey,
            superwallAPIKey: superwallAPIKey,
            environment: environment
        )
        
        do {
            try config.validate()
        } catch {
            logger.error("Configuration validation failed: \(error.localizedDescription)")
            throw error
        }
        
        // Store configuration securely
        self.configuration = config
        
        // Initialize services
        do {
            try configurePostHog(config: config)
            try configureMixpanel(config: config)
            try configureTelemetryDeck(config: config)
            try configureSentry(config: config)
            try configureRevenueCat(config: config)
            
            // Platform-specific configuration will be handled by platform targets
            
            isConfigured = true
            logger.info("AnalyticsPurchaseKit successfully configured for \(environment.rawValue)")
            
        } catch {
            logger.error("Service configuration failed: \(error.localizedDescription)")
            // Clear configuration on failure
            self.configuration = nil
            throw error
        }
    }
    
    /// Check if the SDK is configured
    public var configured: Bool {
        return isConfigured
    }
    
    /// Get current environment (nil if not configured)
    public var currentEnvironment: Environment? {
        return configuration?.environment
    }
    
    // MARK: - Private Configuration Methods
    
    private func configurePostHog(config: SecureConfiguration) throws {
        let posthogConfig = PostHogConfig(apiKey: config.posthogKey)
        posthogConfig.debug = config.environment.isDebug
        
        // Configure for EU if needed (can be made configurable later)
        // Note: PostHog host configuration may vary by SDK version
        
        PostHogSDK.shared.setup(posthogConfig)
        
        if config.environment.isDebug {
            logger.debug("PostHog configured with debug mode enabled")
        }
    }
    
    private func configureMixpanel(config: SecureConfiguration) throws {
        let mixpanel = Mixpanel.initialize(token: config.mixpanelKey)
        
        if config.environment.isDebug {
            mixpanel.loggingEnabled = true
            logger.debug("Mixpanel configured with logging enabled")
        }
        
        // Configure for EU server
        mixpanel.serverURL = "https://api-eu.mixpanel.com"
    }
    
    private func configureTelemetryDeck(config: SecureConfiguration) throws {
        let configuration = TelemetryManagerConfiguration(appID: config.telemetryDeckAppID)
        
        if config.environment.isDebug {
            configuration.analyticsDisabled = false // Enable for testing in debug
            logger.debug("TelemetryDeck configured for debug environment")
        }
        
        TelemetryManager.initialize(with: configuration)
    }
    
    private func configureSentry(config: SecureConfiguration) throws {
        SentrySDK.start { options in
            options.dsn = config.sentryDSN
            options.environment = config.environment.rawValue
            options.debug = config.environment.isDebug
            
            // Configure performance monitoring
            options.tracesSampleRate = config.environment.isDebug ? 1.0 : 0.1
            
            // Configure release tracking
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                options.releaseName = version
            }
        }
        
        if config.environment.isDebug {
            logger.debug("Sentry configured with debug mode and full tracing")
        }
    }
    
    private func configureRevenueCat(config: SecureConfiguration) throws {
        if config.environment.isDebug {
            Purchases.logLevel = .debug
            logger.debug("RevenueCat configured with debug logging")
        }
        
        Purchases.configure(withAPIKey: config.revenueCatAPIKey)
        
        // Enable attribution collection
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
    }
    
    // MARK: - Internal Access for Platform Extensions
    
    /// Internal access to configuration for platform-specific extensions
    internal var internalConfiguration: SecureConfiguration? {
        return configuration
    }
} 