import OSLog

/// Logging-backed feature flag client with empty implementations.
public extension FeatureFlagClient {
    static let empty: Self = {
        let logger = Logger(subsystem: "SwiftAnalyticsKitInterface", category: "EmptyFeatureFlagClient")
        return Self(
            configure: { key in
                logger.debug("EmptyFeatureFlagClient.configure(key:) invoked for key \(key, privacy: .public)")
            },
            isFeatureFlagEnabled: { key in
                logger.debug("EmptyFeatureFlagClient.isFeatureFlagEnabled(_:) invoked for key \(key, privacy: .public)")
                return false
            },
            featureFlagPayloadIfEnabled: { key in
                logger.debug("EmptyFeatureFlagClient.featureFlagPayloadIfEnabled(_:) invoked for key \(key, privacy: .public)")
                return nil
            },
            featureFlagVariant: { key in
                logger.debug("EmptyFeatureFlagClient.featureFlagVariant(_:) invoked for key \(key, privacy: .public)")
                return nil
            },
            isFeatureFlagInVariant: { key, variant in
                logger.debug("EmptyFeatureFlagClient.isFeatureFlag(_:inVariant:) invoked for key \(key, privacy: .public) variant \(variant, privacy: .public)")
                return false
            },
            featureFlagPayload: { key, variant in
                logger.debug("EmptyFeatureFlagClient.featureFlagPayload(_:matching:) invoked for key \(key, privacy: .public) variant \(variant, privacy: .public)")
                return nil
            }
        )
    }()
}
