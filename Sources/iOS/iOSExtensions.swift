import Foundation
import Core
import SuperwallKit

#if os(iOS)
import UIKit

/// iOS-specific extensions for AnalyticsPurchaseKit
extension AnalyticsPurchaseKit {
    
    /// Configure Superwall for iOS paywall management
    /// - Parameter apiKey: Superwall API key
    public func configureSuperwall(apiKey: String, environment: Environment) {
        Superwall.configure(apiKey: apiKey)
        
        if environment == .development {
            Superwall.shared.options.isDebugMode = true
        }
        
        print("AnalyticsPurchaseKit: Superwall configured for iOS")
    }
}

/// iOS-specific paywall manager
public final class PaywallManager {
    
    /// Shared instance
    public static let shared = PaywallManager()
    
    private init() {}
    
    /// Present paywall if needed based on Superwall logic
    /// - Parameter placement: Superwall placement identifier
    public func presentIfNeeded(placement: String = "default") {
        Superwall.shared.register(event: placement)
    }
    
    /// Present paywall unconditionally
    /// - Parameter placement: Superwall placement identifier
    public func present(placement: String = "default") {
        // Implementation will be added in later tasks
        print("PaywallManager: Presenting paywall for placement: \(placement)")
    }
}

#endif 