import AnalyticsManagerInterface

public final class MockFeatureFlagManager: FeatureFlagManaging {
    public private(set) var userID: String?
    public private(set) var posthogAPIKey: String?
    public struct Override {
        public var isEnabled: Bool
        public var variant: String?
        public var payload: AnalyticsFeatureFlagPayload?

        public init(isEnabled: Bool, variant: String? = nil, payload: AnalyticsFeatureFlagPayload? = nil) {
            self.isEnabled = isEnabled
            self.variant = variant
            self.payload = payload
        }
    }

    public var overrides: [String: Override] = [:]
    public private(set) var configuredKey: String?

    public init() {}

    public func configure(posthogAPIKey: String) {
        configuredKey = posthogAPIKey
        self.posthogAPIKey = posthogAPIKey
    }

    public func setUserID(_ userID: String?) {
        self.userID = userID
    }

    public func isFeatureFlagEnabled(_ key: String) -> Bool {
        overrides[key]?.isEnabled ?? false
    }

    public func featureFlagPayloadIfEnabled(_ key: String) -> AnalyticsFeatureFlagPayload? {
        guard let override = overrides[key], override.isEnabled else {
            return nil
        }
        return override.payload
    }

    public func featureFlagVariant(_ key: String) -> String? {
        overrides[key]?.variant
    }

    public func isFeatureFlag(_ key: String, inVariant variant: String) -> Bool {
        featureFlagVariant(key) == variant
    }

    public func featureFlagPayload(_ key: String, matching variant: String) -> AnalyticsFeatureFlagPayload? {
        guard let override = overrides[key], override.variant == variant else {
            return nil
        }
        return override.payload
    }
}
