import Foundation
import Core
import SuperwallKit
import OSLog

#if os(iOS)
import UIKit

/// iOS-specific extensions for AnalyticsPurchaseKit
extension AnalyticsPurchaseKit {
    
    /// Configure Superwall for iOS paywall management
    /// - Parameter apiKey: Superwall API key
    /// - Parameter environment: Environment configuration
    /// - Throws: ConfigurationError if Superwall configuration fails
    public func configureSuperwall(apiKey: String, environment: Environment) throws {
        do {
            Superwall.configure(apiKey: apiKey)
            
            if environment.isDebug {
                Superwall.shared.options.isDebugMode = true
                Logger(subsystem: "com.analyticspurchasekit", category: "iOS").debug("Superwall configured with debug mode enabled")
            }
            
            Logger(subsystem: "com.analyticspurchasekit", category: "iOS").info("Superwall configured for iOS")
            
        } catch {
            throw ConfigurationError.configurationFailed(service: "Superwall", reason: error.localizedDescription)
        }
    }
    
    /// Configure Superwall using the internal configuration
    /// This method is called automatically during the main configuration process
    public func configureSuperwallFromConfig() throws {
        guard let config = internalConfiguration,
              let superwallKey = config.superwallAPIKey else {
            // Superwall is optional, so this is not an error
            return
        }
        
        try configureSuperwall(apiKey: superwallKey, environment: config.environment)
    }
}

/// iOS-specific paywall manager
public final class PaywallManager {
    
    /// Shared instance
    public static let shared = PaywallManager()
    
    /// Logger for paywall operations
    private let logger = Logger(subsystem: "com.analyticspurchasekit", category: "PaywallManager")
    
    private init() {}
    
    /// Present paywall if needed based on Superwall logic
    /// - Parameter placement: Superwall placement identifier
    /// - Throws: ConfigurationError if not properly configured
    public func presentIfNeeded(placement: String = "default") throws {
        guard AnalyticsPurchaseKit.shared.configured else {
            throw AnalyticsPurchaseKit.ConfigurationError.configurationFailed(
                service: "PaywallManager", 
                reason: "AnalyticsPurchaseKit must be configured before using PaywallManager"
            )
        }
        
        logger.info("Presenting paywall if needed for placement: \(placement)")
        Superwall.shared.register(event: placement)
    }
    
    /// Present paywall unconditionally
    /// - Parameter placement: Superwall placement identifier
    /// - Throws: ConfigurationError if not properly configured
    public func present(placement: String = "default") throws {
        guard AnalyticsPurchaseKit.shared.configured else {
            throw AnalyticsPurchaseKit.ConfigurationError.configurationFailed(
                service: "PaywallManager", 
                reason: "AnalyticsPurchaseKit must be configured before using PaywallManager"
            )
        }
        
        logger.info("Presenting paywall for placement: \(placement)")
        // Implementation will be enhanced in later tasks
        Superwall.shared.register(event: placement)
    }
    
    /// Check if Superwall is available and configured
    public var isAvailable: Bool {
        return AnalyticsPurchaseKit.shared.configured && 
               AnalyticsPurchaseKit.shared.internalConfiguration?.superwallAPIKey != nil
    }
}

#endif 