import Foundation
import Observation
import SwiftUI

/// Observable base analytics manager with empty implementations.
@Observable
open class EmptyAnalyticsManager: AnalyticsManaging {
    public private(set) var configuration: AnalyticsConfiguration

    public init(configuration: AnalyticsConfiguration = .init()) {
        self.configuration = configuration
    }

    open var isSuperwallEnabled: Bool { false }

    open func configure(using configuration: AnalyticsConfiguration) {
        self.configuration = configuration
    }

    open func initializeIfNeeded(userDefaults: UserDefaults) {
        // empty
    }

    open func track(_ event: AnalyticsEvent) {
        // empty
    }

    open func setUserIdentity(_ identity: AnalyticsUserIdentity) {
        // empty
    }

    open func setUserAttribute(_ key: String, value: AnalyticsAttributeValue) {
        // empty
    }

    open func incrementUserAttribute(_ key: String, by value: Double) {
        // empty
    }

    open func setSubscriptionStatus(isActive: Bool, key: String) {
        // empty
    }

    open func handlePlacement(_ placement: String, params: [String: Any], completion: @escaping () -> Void) {
        completion()
    }

    open func makeCustomerCenterView() -> AnyView {
        AnyView(EmptyView())
    }
}
