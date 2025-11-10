import Foundation
import OSLog
import SwiftUI

/// Logging-backed analytics client with empty implementations.
public extension AnalyticsClient {
    static let empty: Self = {
        let logger = Logger(subsystem: "SwiftAnalyticsKitInterface", category: "EmptyAnalyticsClient")
        return Self(
            configuration: { .init() },
            isSuperwallEnabled: { false },
            configure: { _ in
                logger.debug("EmptyAnalyticsClient.configure(using:) invoked")
            },
            initializeIfNeeded: { _ in
                logger.debug("EmptyAnalyticsClient.initializeIfNeeded(userDefaults:) invoked")
            },
            track: { event in
                logger.debug("EmptyAnalyticsClient.track(_:) invoked for event \(event.name, privacy: .public)")
            },
            setUserIdentity: { identity in
                logger.debug("EmptyAnalyticsClient.setUserIdentity(_:) invoked for id \(identity.id, privacy: .public)")
            },
            setUserAttribute: { key, _ in
                logger.debug("EmptyAnalyticsClient.setUserAttribute(_:value:) invoked for key \(key, privacy: .public)")
            },
            incrementUserAttribute: { key, value in
                logger.debug("EmptyAnalyticsClient.incrementUserAttribute(_:by:) invoked for key \(key, privacy: .public) by \(value.formatted())")
            },
            setSubscriptionStatus: { isActive, key in
                logger.debug("EmptyAnalyticsClient.setSubscriptionStatus(isActive:key:) invoked for key \(key, privacy: .public) active \(isActive, privacy: .public)")
            },
            handlePlacement: { placement, params, completion in
                logger.debug("EmptyAnalyticsClient.handlePlacement(_:params:) invoked for placement \(placement, privacy: .public) with \(params.count.formatted()) params")
                completion()
            },
            makeCustomerCenterView: {
                logger.debug("EmptyAnalyticsClient.makeCustomerCenterView() invoked")
                return AnyView(Text("Customer Center"))
            }
        )
    }()
}
