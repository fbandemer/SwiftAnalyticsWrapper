import Dependencies
import PostHog
import SwiftAnalyticsKitInterface

private enum FeatureFlagClientDefaults {
    static let posthogHost = "https://eu.i.posthog.com"
}

public extension FeatureFlagClient {
    static func posthog() -> Self {
        return Self(
            configure: { key in
                var config = PostHogConfig(apiKey: key, host: FeatureFlagClientDefaults.posthogHost)
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
            },
            isFeatureFlagEnabled: { key in
                PostHogSDK.shared.isFeatureEnabled(key)
            },
            featureFlagPayloadIfEnabled: { key in
                guard PostHogSDK.shared.isFeatureEnabled(key) else {
                    return nil
                }
                return Self.payload(for: key)
            },
            featureFlagVariant: { key in
                PostHogSDK.shared.getFeatureFlag(key) as? String
            },
            isFeatureFlagInVariant: { key, variant in
                guard let currentVariant = PostHogSDK.shared.getFeatureFlag(key) as? String else {
                    return false
                }
                return currentVariant == variant
            },
            featureFlagPayload: { key, variant in
                guard let currentVariant = PostHogSDK.shared.getFeatureFlag(key) as? String,
                      currentVariant == variant
                else {
                    return nil
                }
                return Self.payload(for: key)
            }
        )
    }
}

extension FeatureFlagClient {
    static func payload(for key: String) -> AnalyticsFeatureFlagPayload? {
        guard let rawPayload = PostHogSDK.shared.getFeatureFlagPayload(key) else {
            return nil
        }
        return AnalyticsFeatureFlagPayload(rawValue: rawPayload)
    }
}

extension FeatureFlagClient: DependencyKey {
    public static let liveValue: FeatureFlagClient = .posthog()
}
