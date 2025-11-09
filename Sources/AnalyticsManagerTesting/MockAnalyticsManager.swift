import Foundation
import SwiftUI
import SwiftAnalyticsKitInterface

public final class MockAnalyticsManager: AnalyticsManaging {
    public private(set) var configuration: AnalyticsConfiguration
    public private(set) var trackedEvents: [AnalyticsEvent] = []
    public private(set) var handledPlacements: [(name: String, params: [String: Any])] = []
    public private(set) var identities: [AnalyticsUserIdentity] = []
    public private(set) var attributes: [(key: String, value: AnalyticsAttributeValue)] = []
    public private(set) var incrementedAttributes: [(key: String, value: Double)] = []
    public private(set) var subscriptionStatuses: [(key: String, isActive: Bool)] = []
    public var superwallEnabled = false
    public var placementCompletionQueue: DispatchQueue = .main
    public var customerCenterViewFactory: () -> AnyView = { AnyView(EmptyView()) }

    public var isSuperwallEnabled: Bool {
        superwallEnabled
    }

    public init(configuration: AnalyticsConfiguration = .init()) {
        self.configuration = configuration
    }

    public func configure(using configuration: AnalyticsConfiguration) {
        self.configuration = configuration
    }

    public func initializeIfNeeded(userDefaults: UserDefaults) {
        // empty
    }

    public func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }

    public func setUserIdentity(_ identity: AnalyticsUserIdentity) {
        identities.append(identity)
    }

    public func setUserAttribute(_ key: String, value: AnalyticsAttributeValue) {
        attributes.append((key, value))
    }

    public func incrementUserAttribute(_ key: String, by value: Double) {
        incrementedAttributes.append((key, value))
    }

    public func setSubscriptionStatus(isActive: Bool, key: String) {
        subscriptionStatuses.append((key, isActive))
    }

    public func handlePlacement(
        _ placement: String,
        params: [String: Any],
        completion: @escaping () -> Void
    ) {
        handledPlacements.append((placement, params))
        placementCompletionQueue.async {
            completion()
        }
    }

    public func makeCustomerCenterView() -> AnyView {
        customerCenterViewFactory()
    }
}
