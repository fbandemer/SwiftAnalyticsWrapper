import Dependencies

/// Struct-based client for evaluating feature flags independently of analytics tracking.
public struct FeatureFlagClient: Sendable {
    public var configure: @Sendable (_ key: String) -> Void
    public var isFeatureFlagEnabled: @Sendable (_ key: String) -> Bool
    public var featureFlagPayloadIfEnabled: @Sendable (_ key: String) -> AnalyticsFeatureFlagPayload?
    public var featureFlagVariant: @Sendable (_ key: String) -> String?
    public var isFeatureFlagInVariant: @Sendable (_ key: String, _ variant: String) -> Bool
    public var featureFlagPayload: @Sendable (_ key: String, _ variant: String) -> AnalyticsFeatureFlagPayload?

    public init(
        configure: @escaping @Sendable (_ key: String) -> Void,
        isFeatureFlagEnabled: @escaping @Sendable (_ key: String) -> Bool,
        featureFlagPayloadIfEnabled: @escaping @Sendable (_ key: String) -> AnalyticsFeatureFlagPayload?,
        featureFlagVariant: @escaping @Sendable (_ key: String) -> String?,
        isFeatureFlagInVariant: @escaping @Sendable (_ key: String, _ variant: String) -> Bool,
        featureFlagPayload: @escaping @Sendable (_ key: String, _ variant: String) -> AnalyticsFeatureFlagPayload?
    ) {
        self.configure = configure
        self.isFeatureFlagEnabled = isFeatureFlagEnabled
        self.featureFlagPayloadIfEnabled = featureFlagPayloadIfEnabled
        self.featureFlagVariant = featureFlagVariant
        self.isFeatureFlagInVariant = isFeatureFlagInVariant
        self.featureFlagPayload = featureFlagPayload
    }
}

extension FeatureFlagClient: TestDependencyKey {
    public static let testValue: Self = .empty
}

public extension DependencyValues {
    var featureFlagClient: FeatureFlagClient {
        get { self[FeatureFlagClient.self] }
        set { self[FeatureFlagClient.self] = newValue }
    }
}
