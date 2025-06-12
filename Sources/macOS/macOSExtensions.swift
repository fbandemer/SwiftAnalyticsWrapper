import Foundation
import Core
import OSLog

#if os(macOS)
import AppKit

/// macOS-specific extensions for AnalyticsPurchaseKit
extension AnalyticsPurchaseKit {
    
    /// Superwall is not available on macOS, so this is a no-op
    /// - Parameter apiKey: Ignored on macOS
    /// - Parameter environment: Ignored on macOS
    /// - Throws: Never throws on macOS
    public func configureSuperwall(apiKey: String, environment: Environment) throws {
        Logger(subsystem: "com.analyticspurchasekit", category: "macOS").info("Superwall not available on macOS, skipping configuration")
    }
    
    /// Configure Superwall using the internal configuration - no-op on macOS
    /// This method is called automatically during the main configuration process
    public func configureSuperwallFromConfig() throws {
        // No-op on macOS - Superwall is not available
        Logger(subsystem: "com.analyticspurchasekit", category: "macOS").debug("Superwall configuration skipped on macOS")
    }
}

/// macOS paywall manager with graceful fallbacks
public final class PaywallManager {
    
    /// Shared instance
    public static let shared = PaywallManager()
    
    /// Logger for paywall operations
    private let logger = Logger(subsystem: "com.analyticspurchasekit", category: "PaywallManager")
    
    private init() {}
    
    /// Present paywall if needed - graceful no-op on macOS
    /// - Parameter placement: Ignored on macOS
    /// - Throws: ConfigurationError if not properly configured
    public func presentIfNeeded(placement: String = "default") throws {
        guard AnalyticsPurchaseKit.shared.configured else {
            throw AnalyticsPurchaseKit.ConfigurationError.configurationFailed(
                service: "PaywallManager", 
                reason: "AnalyticsPurchaseKit must be configured before using PaywallManager"
            )
        }
        
        logger.info("Paywall presentation not supported on macOS (placement: \(placement))")
    }
    
    /// Present paywall unconditionally - graceful no-op on macOS
    /// - Parameter placement: Ignored on macOS
    /// - Throws: ConfigurationError if not properly configured
    public func present(placement: String = "default") throws {
        guard AnalyticsPurchaseKit.shared.configured else {
            throw AnalyticsPurchaseKit.ConfigurationError.configurationFailed(
                service: "PaywallManager", 
                reason: "AnalyticsPurchaseKit must be configured before using PaywallManager"
            )
        }
        
        logger.info("Paywall presentation not supported on macOS (placement: \(placement))")
    }
    
    /// Check if Superwall is available - always false on macOS
    public var isAvailable: Bool {
        return false
    }
}

#endif 