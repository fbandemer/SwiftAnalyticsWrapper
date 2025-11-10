import Foundation
import RevenueCat
import SwiftAnalyticsKitInterface

public extension AnalyticsClient {
    /// Validates naming, tracks the event, and executes the action once placements finish.
    func performEvent(
        category: some AnalyticsCategory,
        object: AnalyticsObject,
        verb: AnalyticsVerb,
        attributes: AnalyticsAttributes = [:],
        action: @escaping AnalyticsAction
    ) {
        guard let event = try? AnalyticsEvent(
            category: category,
            object: object,
            verb: verb,
            properties: attributes
        ) else {
            assertionFailure("Invalid analytics naming for placement")
            return
        }

        track(event)
        handlePlacement(event.name, event.properties.toAnyDictionary()) {
            action()
        }
    }

    func setUserID(_ userID: String) {
        setUserIdentity(.init(id: userID))
    }

    func setUserID(
        _ userID: String,
        email: String?,
        oneSignalUserID: String? = nil,
        attributes: AnalyticsAttributes = [:]
    ) {
        setUserIdentity(
            .init(
                id: userID,
                email: email,
                pushToken: oneSignalUserID,
                attributes: attributes
            )
        )
    }

    func setSubscriptionStatus(active: Bool, key: String) {
        setSubscriptionStatus(active, key)
    }

    func incrementAttribute(key: String, value: Double) {
        incrementUserAttribute(key, value)
    }

    func setRCAttributionConsent() {
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
    }

    func restorePurchases() async throws -> RevenueCat.CustomerInfo {
        try await Purchases.shared.restorePurchases()
    }
}
