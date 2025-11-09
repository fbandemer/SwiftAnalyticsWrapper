import Foundation
import Observation

/// Observable base feature flag manager with empty implementations.
@Observable
open class EmptyFeatureFlagManager: FeatureFlagManaging {
    public init() {}

    open func configure(key: String) {
        // empty
    }

    open func isFeatureFlagEnabled(_ key: String) -> Bool {
        false
    }

    open func featureFlagPayloadIfEnabled(_ key: String) -> AnalyticsFeatureFlagPayload? {
        nil
    }

    open func featureFlagVariant(_ key: String) -> String? {
        nil
    }

    open func isFeatureFlag(_ key: String, inVariant variant: String) -> Bool {
        false
    }

    open func featureFlagPayload(_ key: String, matching variant: String) -> AnalyticsFeatureFlagPayload? {
        nil
    }
}
