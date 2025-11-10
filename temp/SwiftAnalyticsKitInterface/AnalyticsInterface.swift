import Dependencies
import Foundation
import SwiftUI

/// Type-safe payload used for analytics calls.
public typealias AnalyticsAttributes = [String: AnalyticsAttributeValue]
public typealias AnalyticsObject = String
public typealias AnalyticsAction = @Sendable () -> Void

/// Categories live in the app layer. Conform any enum to this protocol to make
/// it usable with the analytics interface while keeping the string raw value in
/// snake_case (e.g. `enum BillingCategory: String, AnalyticsCategory { case account_settings }`).
public protocol AnalyticsCategory: RawRepresentable, Sendable where RawValue == String {}

/// Closure-based client describing analytics integrations.
public struct AnalyticsClient: Sendable {
    public var configuration: AnalyticsConfiguration
    public var isSuperwallEnabled: Bool
    public var userID: String?
    public var configure: @Sendable (_ configuration: AnalyticsConfiguration, _ userDefaults: UserDefaults) -> Void
    public var track: @Sendable (_ event: AnalyticsEvent) -> Void
    public var setUserIdentity: @Sendable (_ identity: AnalyticsUserIdentity) -> Void
    public var setUserAttribute: @Sendable (_ key: String, _ value: AnalyticsAttributeValue) -> Void
    public var incrementUserAttribute: @Sendable (_ key: String, _ value: Double) -> Void
    public var setSubscriptionStatus: @Sendable (_ isActive: Bool, _ key: String) -> Void
    public var handlePlacement: @Sendable (_ placement: String, _ params: [String: Any], _ completion: @escaping AnalyticsAction) -> Void
    public var makeCustomerCenterView: @Sendable () -> AnyView

    public init(
        configuration: AnalyticsConfiguration,
        isSuperwallEnabled: Bool,
        configure: @escaping @Sendable (_ configuration: AnalyticsConfiguration, _ userDefaults: UserDefaults) -> Void,
        track: @escaping @Sendable (_ event: AnalyticsEvent) -> Void,
        setUserIdentity: @escaping @Sendable (_ identity: AnalyticsUserIdentity) -> Void,
        setUserAttribute: @escaping @Sendable (_ key: String, _ value: AnalyticsAttributeValue) -> Void,
        incrementUserAttribute: @escaping @Sendable (_ key: String, _ value: Double) -> Void,
        setSubscriptionStatus: @escaping @Sendable (_ isActive: Bool, _ key: String) -> Void,
        handlePlacement: @escaping @Sendable (_ placement: String, _ params: [String: Any], _ completion: @escaping AnalyticsAction) -> Void,
        makeCustomerCenterView: @escaping @Sendable () -> AnyView
    ) {
        self.configuration = configuration
        self.isSuperwallEnabled = isSuperwallEnabled
        self.configure = configure
        self.track = track
        self.setUserIdentity = setUserIdentity
        self.setUserAttribute = setUserAttribute
        self.incrementUserAttribute = incrementUserAttribute
        self.setSubscriptionStatus = setSubscriptionStatus
        self.handlePlacement = handlePlacement
        self.makeCustomerCenterView = makeCustomerCenterView
    }
}

extension AnalyticsClient: TestDependencyKey {
    public static let testValue: Self = .empty
}

public extension DependencyValues {
    var analytics: AnalyticsClient {
        get { self[AnalyticsClient.self] }
        set { self[AnalyticsClient.self] = newValue }
    }
}
