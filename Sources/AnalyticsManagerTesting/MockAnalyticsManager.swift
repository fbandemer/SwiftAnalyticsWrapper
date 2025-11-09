import Foundation
import AnalyticsManagerInterface

public final class MockAnalyticsManager: AnalyticsManagerInterface.AnalyticsManager {
    public private(set) var trackedEvents: [AnalyticsEvent] = []
    public private(set) var handledPlacements: [(name: String, params: [String: Any])] = []
    public private(set) var identities: [AnalyticsUserIdentity] = []
    public private(set) var attributes: [(key: String, value: AnalyticsAttributeValue)] = []
    public private(set) var incrementedAttributes: [(key: String, value: Double)] = []
    public private(set) var subscriptionStatuses: [(key: String, isActive: Bool)] = []
    public var superwallEnabled = false
    public var placementCompletionQueue: DispatchQueue = .main

    public override var isSuperwallEnabled: Bool {
        superwallEnabled
    }

    public override func track(_ event: AnalyticsEvent) {
        trackedEvents.append(event)
    }

    public override func setUserIdentity(_ identity: AnalyticsUserIdentity) {
        identities.append(identity)
    }

    public override func setUserAttribute(_ key: String, value: AnalyticsAttributeValue) {
        attributes.append((key, value))
    }

    public override func incrementUserAttribute(_ key: String, by value: Double) {
        incrementedAttributes.append((key, value))
    }

    public override func setSubscriptionStatus(isActive: Bool, key: String) {
        subscriptionStatuses.append((key, isActive))
    }

    public override func handlePlacement(
        _ placement: String,
        params: [String: Any],
        completion: @escaping () -> Void
    ) {
        handledPlacements.append((placement, params))
        placementCompletionQueue.async {
            completion()
        }
    }
}
