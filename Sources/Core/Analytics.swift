import Foundation
import PostHog
import Mixpanel
import TelemetryClient
import OSLog

#if os(iOS)
import UIKit
#endif

/// Standardized action verbs for analytics events
public enum EventVerb: String, CaseIterable {
    case viewed = "viewed"
    case tapped = "tapped"
    case started = "started"
    case completed = "completed"
    case purchased = "purchased"
    case cancelled = "cancelled"
    case opened = "opened"
    case closed = "closed"
    case submitted = "submitted"
    case failed = "failed"
    case shared = "shared"
    case downloaded = "downloaded"
    case uploaded = "uploaded"
    case searched = "searched"
    case filtered = "filtered"
    case sorted = "sorted"
    case selected = "selected"
    case deselected = "deselected"
    case enabled = "enabled"
    case disabled = "disabled"
    case created = "created"
    case deleted = "deleted"
    case updated = "updated"
    case refreshed = "refreshed"
    case expanded = "expanded"
    case collapsed = "collapsed"
    case navigated = "navigated"
    case authenticated = "authenticated"
    case signedOut = "signed_out"
    case registered = "registered"
    case subscribed = "subscribed"
    case unsubscribed = "unsubscribed"
}

/// Analytics-specific errors
public enum AnalyticsError: Error, LocalizedError {
    case invalidEventName(String)
    case notConfigured
    case invalidCategory(String)
    case invalidObject(String)
    case providerError(provider: String, error: Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidEventName(let name):
            return "Invalid event name format: '\(name)'. Expected format: 'category:object_action'"
        case .notConfigured:
            return "Analytics not configured. Please configure AnalyticsPurchaseKit before tracking events."
        case .invalidCategory(let category):
            return "Invalid category: '\(category)'. Category must contain only alphanumeric characters and underscores."
        case .invalidObject(let object):
            return "Invalid object: '\(object)'. Object must contain only alphanumeric characters and underscores."
        case .providerError(let provider, let error):
            return "Provider '\(provider)' error: \(error.localizedDescription)"
        }
    }
}

/// Core analytics tracking class with thread-safe operations and provider dispatching
public final class Analytics {
    
    /// Shared singleton instance
    public private(set) static var shared: Analytics = Analytics()
    
    /// Initialize the singleton with an optional userId (must be called before first use)
    /// - Parameter userId: Optional user identifier to associate with analytics events
    public static func initialize(userId: String? = nil) {
        let instance = Analytics(userId: userId)
        Analytics.shared = instance
    }
    
    /// The current user identifier (optional)
    private(set) var userId: String?
    
    /// Logger for analytics operations
    private let logger = Logger(subsystem: "com.analyticspurchasekit", category: "Analytics")
    
    /// Validation regex patterns
    private let categoryPattern = "^[a-zA-Z0-9_]+$"
    private let objectPattern = "^[a-zA-Z0-9_]+$"
    
    private init(userId: String? = nil) {
        self.userId = userId
        if let userId = userId {
            setUserIdForProviders(userId)
        }
    }
    
    // MARK: - Public Tracking Methods
    
    /// Track an analytics event with standardized naming convention
    /// - Parameters:
    ///   - category: Event category (e.g., "user", "purchase", "navigation")
    ///   - object: Object being acted upon (e.g., "profile", "product", "screen")
    ///   - verb: Standardized action verb
    ///   - params: Additional event parameters
    /// - Throws: AnalyticsError if validation fails or not configured
    public func track(
        category: String,
        object: String,
        verb: EventVerb,
        params: [String: Any] = [:]
    ) throws {
        guard AnalyticsPurchaseKit.shared.configured else {
            throw AnalyticsError.notConfigured
        }
        
        // Validate category and object, but always send event
        if !validateCategory(category) {
            logger.warning("[Analytics] Category validation failed: \(category). Must be alphanumeric/underscore.")
        }
        if !validateObject(object) {
            logger.warning("[Analytics] Object validation failed: \(object). Must be alphanumeric/underscore.")
        }
        
        // Create standardized event name
        let eventName = "\(category):\(object)_\(verb.rawValue)"
        
        // Directly call provider methods (frameworks handle their own threading)
        dispatchToProviders(eventName: eventName, parameters: params)
        
        logger.info("Tracked event: \(eventName)")
    }
    
    /// Track a custom event with manual name validation
    /// - Parameters:
    ///   - eventName: Custom event name (must follow category:object_action format)
    ///   - params: Event parameters
    /// - Throws: AnalyticsError if not configured
    public func trackCustom(
        eventName: String,
        params: [String: Any] = [:]
    ) throws {
        guard AnalyticsPurchaseKit.shared.configured else {
            throw AnalyticsError.notConfigured
        }
        
        // Validate event name format, but always send event
        if !validateEventName(eventName) {
            logger.warning("[Analytics] Event name validation failed: \(eventName). Expected format: category:object_action")
        }
        
        // Directly call provider methods (frameworks handle their own threading)
        dispatchToProviders(eventName: eventName, parameters: params)
        
        logger.info("Tracked custom event: \(eventName)")
    }
    
    /// Manually flush all pending events (no-op since frameworks handle batching)
    public func flush() {
        // The individual analytics frameworks handle their own batching and flushing
        // This method is kept for API compatibility but doesn't need to do anything
        logger.debug("Flush called - frameworks handle batching internally")
    }
    
    // MARK: - Private Validation Methods
    
    private func validateCategory(_ category: String) -> Bool {
        guard !category.isEmpty else { return false }
        return category.range(of: categoryPattern, options: .regularExpression) != nil
    }
    
    private func validateObject(_ object: String) -> Bool {
        guard !object.isEmpty else { return false }
        return object.range(of: objectPattern, options: .regularExpression) != nil
    }
    
    private func validateEventName(_ eventName: String) -> Bool {
        // Expected format: category:object_action
        let components = eventName.components(separatedBy: ":")
        guard components.count == 2 else { return false }
        let category = components[0]
        let objectAction = components[1]
        guard validateCategory(category) else { return false }
        let objectActionComponents = objectAction.components(separatedBy: "_")
        guard objectActionComponents.count >= 2 else { return false }
        let object = objectActionComponents.dropLast().joined(separator: "_")
        return validateObject(object)
    }
    
    // MARK: - Provider Dispatching
    
    private func dispatchToProviders(eventName: String, parameters: [String: Any]) {
        // Dispatch to PostHog
        dispatchToPostHog(eventName: eventName, parameters: parameters)
        
        // Dispatch to Mixpanel
        dispatchToMixpanel(eventName: eventName, parameters: parameters)
        
        // Dispatch to TelemetryDeck
        dispatchToTelemetryDeck(eventName: eventName, parameters: parameters)
    }
    
    private func dispatchToPostHog(eventName: String, parameters: [String: Any]) {
        PostHogSDK.shared.capture(eventName, properties: parameters)
    }
    
    private func dispatchToMixpanel(eventName: String, parameters: [String: Any]) {
        let mixpanelInstance = Mixpanel.mainInstance()
        // Convert parameters to [String: MixpanelType]
        var mixpanelProps: [String: MixpanelType] = [:]
        for (key, value) in parameters {
            if let v = value as? MixpanelType {
                mixpanelProps[key] = v
            } else if let v = value as? CustomStringConvertible {
                mixpanelProps[key] = v.description
            }
        }
        // Track the event with properties
        mixpanelInstance.track(event: eventName, properties: mixpanelProps)
    }
    
    private func dispatchToTelemetryDeck(eventName: String, parameters: [String: Any]) {
        // TelemetryDeck uses signals with string parameters
        var stringParams: [String: String] = [:]
        for (key, value) in parameters {
            stringParams[key] = String(describing: value)
        }
        
        TelemetryManager.send(eventName, with: stringParams)
    }
    
    /// Set the user identifier for all analytics providers
    /// - Parameter userId: The user identifier to associate with analytics events
    public func setUserId(_ userId: String) {
        self.userId = userId
        setUserIdForProviders(userId)
        logger.info("Set userId for analytics: \(userId)")
    }
    
    /// Reset/clear the user identifier for all analytics providers
    public func resetUserId() {
        self.userId = nil
        resetUserIdForProviders()
        logger.info("Reset userId for analytics")
    }
    
    /// Internal: Set userId for all providers
    private func setUserIdForProviders(_ userId: String) {
        PostHogSDK.shared.identify(userId)
        Mixpanel.mainInstance().identify(distinctId: userId)
        // TelemetryDeck does not support direct user ID assignment
    }
    
    /// Internal: Reset userId for all providers
    private func resetUserIdForProviders() {
        PostHogSDK.shared.reset()
        Mixpanel.mainInstance().reset()
        // TelemetryDeck does not support direct user ID assignment
    }
}

// MARK: - Convenience Extensions

public extension Analytics {
    
    /// Track a screen view event
    /// - Parameters:
    ///   - screenName: Name of the screen
    ///   - params: Additional parameters
    func trackScreenView(_ screenName: String, params: [String: Any] = [:]) throws {
        try track(category: "screen", object: screenName, verb: .viewed, params: params)
    }
    
    /// Track a button tap event
    /// - Parameters:
    ///   - buttonName: Name of the button
    ///   - params: Additional parameters
    func trackButtonTap(_ buttonName: String, params: [String: Any] = [:]) throws {
        try track(category: "button", object: buttonName, verb: .tapped, params: params)
    }
    
    /// Track a purchase event
    /// - Parameters:
    ///   - productId: Product identifier
    ///   - params: Additional parameters (should include price, currency, etc.)
    func trackPurchase(_ productId: String, params: [String: Any] = [:]) throws {
        try track(category: "product", object: productId, verb: .purchased, params: params)
    }
    
    /// Track a user registration event
    /// - Parameters:
    ///   - method: Registration method (email, social, etc.)
    ///   - params: Additional parameters
    func trackRegistration(_ method: String, params: [String: Any] = [:]) throws {
        try track(category: "user", object: method, verb: .registered, params: params)
    }
    
    /// Track a search event
    /// - Parameters:
    ///   - query: Search query
    ///   - params: Additional parameters
    func trackSearch(_ query: String, params: [String: Any] = [:]) throws {
        var searchParams = params
        searchParams["query"] = query
        try track(category: "search", object: "query", verb: .searched, params: searchParams)
    }
} 