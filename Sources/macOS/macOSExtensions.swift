import Foundation
import Core

#if os(macOS)
import AppKit

/// macOS-specific extensions for AnalyticsPurchaseKit
extension AnalyticsPurchaseKit {
    
    /// Superwall is not available on macOS, so this is a no-op
    /// - Parameter apiKey: Ignored on macOS
    public func configureSuperwall(apiKey: String, environment: Environment) {
        print("AnalyticsPurchaseKit: Superwall not available on macOS, skipping configuration")
    }
}

/// macOS paywall manager with graceful fallbacks
public final class PaywallManager {
    
    /// Shared instance
    public static let shared = PaywallManager()
    
    private init() {}
    
    /// Present paywall if needed - graceful no-op on macOS
    /// - Parameter placement: Ignored on macOS
    public func presentIfNeeded(placement: String = "default") {
        print("PaywallManager: Paywall presentation not supported on macOS")
    }
    
    /// Present paywall unconditionally - graceful no-op on macOS
    /// - Parameter placement: Ignored on macOS
    public func present(placement: String = "default") {
        print("PaywallManager: Paywall presentation not supported on macOS")
    }
}

#endif 