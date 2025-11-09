import SwiftAnalyticsKitInterface
import Foundation
import Observation
import PostHog

/// PostHog-backed feature flag manager shared across the analytics package.
@Observable
public final class PosthogFeatureManager: FeatureFlagManaging {
    private var posthogAPIKey: String?

    private static let defaultHost = "https://eu.i.posthog.com"

    public nonisolated(unsafe) static let shared = PosthogFeatureManager()

    public init() {}

    public func configure(key: String) {
        posthogAPIKey = key

        let config = PostHogConfig(apiKey: key, host: Self.defaultHost)
#if os(iOS)
        config.sessionReplay = true
        config.captureElementInteractions = false
        config.sessionReplayConfig.screenshotMode = true
        config.sessionReplayConfig.maskAllTextInputs = false
        config.sessionReplayConfig.maskAllImages = false
#endif
        config.personProfiles = .identifiedOnly

#if DEBUG
        config.debug = true
#endif

        PostHogSDK.shared.setup(config)
    }

    public func isFeatureFlagEnabled(_ key: String) -> Bool {
        guard posthogAPIKey != nil else {
            return false
        }
        return PostHogSDK.shared.isFeatureEnabled(key)
    }

    public func featureFlagPayloadIfEnabled(_ key: String) -> AnalyticsFeatureFlagPayload? {
        guard posthogAPIKey != nil, PostHogSDK.shared.isFeatureEnabled(key) else {
            return nil
        }
        return payload(for: key)
    }

    public func featureFlagVariant(_ key: String) -> String? {
        guard posthogAPIKey != nil else {
            return nil
        }
        return PostHogSDK.shared.getFeatureFlag(key) as? String
    }

    public func isFeatureFlag(_ key: String, inVariant variant: String) -> Bool {
        guard let currentVariant = featureFlagVariant(key) else {
            return false
        }
        return currentVariant == variant
    }

    public func featureFlagPayload(_ key: String, matching variant: String) -> AnalyticsFeatureFlagPayload? {
        guard posthogAPIKey != nil, featureFlagVariant(key) == variant else {
            return nil
        }
        return payload(for: key)
    }

    private func payload(for key: String) -> AnalyticsFeatureFlagPayload? {
        guard let rawPayload = PostHogSDK.shared.getFeatureFlagPayload(key) else {
            return nil
        }
        return AnalyticsFeatureFlagPayload(rawValue: rawPayload)
    }
}
