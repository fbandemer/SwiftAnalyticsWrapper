import Foundation
import SwiftUI
import SwiftAnalyticsKitInterface

public final class MockAnalyticsManager {
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

    public lazy var client: AnalyticsClient = {
        AnalyticsClient(
            configuration: configuration,
            isSuperwallEnabled: isSuperwallEnabled,
            configure: { [unowned self] configuration, _ in
                self.configure(using: configuration)
            },
            track: { [unowned self] event in
                self.track(event)
            },
            setUserIdentity: { [unowned self] identity in
                self.setUserIdentity(identity)
            },
            setUserAttribute: { [unowned self] key, value in
                self.setUserAttribute(key, value: value)
            },
            incrementUserAttribute: { [unowned self] key, value in
                self.incrementUserAttribute(key, by: value)
            },
            setSubscriptionStatus: { [unowned self] isActive, key in
                self.setSubscriptionStatus(isActive: isActive, key: key)
            },
            handlePlacement: { [unowned self] placement, params, completion in
                self.handlePlacement(placement, params: params, completion: completion)
            },
            makeCustomerCenterView: { [unowned self] in
                self.makeCustomerCenterView()
            }
        )
    }()

    public init(configuration: AnalyticsConfiguration = .init()) {
        self.configuration = configuration
    }

    public func configure(using configuration: AnalyticsConfiguration) {
        self.configuration = configuration
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
