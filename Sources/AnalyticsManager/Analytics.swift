
import Dependencies
import Foundation
import OSLog
import PostHog
import RevenueCat
import SwiftAnalyticsKitInterface
import SwiftUI

private enum AnalyticsClientDefaults {
    static let subsystem = "Analytics"
    static let category = "Default"
    static let posthogHost = "https://eu.i.posthog.com"
}

public extension AnalyticsClient {
    static func `default`() -> Self {
        var logger = Logger(subsystem: AnalyticsClientDefaults.subsystem, category: AnalyticsClientDefaults.category)
        return Self(
            logger: logger,
            configure: { newConfiguration, _ in
                Self.configurePosthog(apiKey: newConfiguration.posthogAPIKey, userId: newConfiguration.userId)
                Self.configureRevenueCat(apiKey: newConfiguration.revenueCatAPIKey, userId: newConfiguration.userId)
                // let subsystem = newConfiguration.loggerSubsystem.isEmpty ? AnalyticsClientDefaults.subsystem : newConfiguration.loggerSubsystem
                // let category = newConfiguration.loggerCategory.isEmpty ? AnalyticsClientDefaults.category : newConfiguration.loggerCategory
                // logger = Logger(subsystem: subsystem, category: category)
            },
            track: { event in
                PostHogSDK.shared.capture(event.name, properties: event.properties.toAnyDictionary())
            },
            setUserIdentity: { identity in
                Self.assignUser(
                    id: identity.id,
                    email: identity.email,
                    oneSignalUserID: identity.pushToken,
                    attributes: identity.attributes.toAnyDictionary()
                )
            },
            setUserAttribute: { key, value in
                Self.setUserAttribute(key: key, rawValue: String(describing: value.anyValue))
            },
            incrementUserAttribute: { key, value in
                Self.updateIncrementedAttribute(key: key, value: value)
            },
            setSubscriptionStatus: { isActive, key in
                Self.setUserAttribute(key: key, rawValue: "\(isActive)")
            },
            makeCustomerCenterView: {
                AnyView(CustomerCenterContainerView())
            }
        )
    }
}

extension AnalyticsClient {
    static func configurePosthog(apiKey: String, userId: String? = nil) {
        var posthogConfig = PostHogConfig(apiKey: apiKey, host: AnalyticsClientDefaults.posthogHost)

        #if os(iOS)
            posthogConfig.sessionReplay = true
            posthogConfig.captureElementInteractions = false
            posthogConfig.sessionReplayConfig.screenshotMode = true
            posthogConfig.sessionReplayConfig.maskAllTextInputs = false
            posthogConfig.sessionReplayConfig.maskAllImages = false
        #endif

        posthogConfig.personProfiles = .identifiedOnly

        #if DEBUG
            posthogConfig.debug = true
        #endif
        PostHogSDK.shared.setup(posthogConfig)
        if let userId {
            PostHogSDK.shared.identify(userId)
        }
    }

    static func configureRevenueCat(apiKey: String, userId: String? = nil) {
        #if DEBUG
            Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: apiKey, appUserID: userId)
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
    }

    static func assignUser(
        id: String,
        email: String?,
        oneSignalUserID: String?,
        attributes newAttributes: [String: Any]?
    ) {
        Purchases.shared.logIn(id) { _, _, _ in }
        if let email {
            Purchases.shared.attribution.setEmail(email)
        }
        if let oneSignalUserID {
            Purchases.shared.attribution.setOnesignalUserID(oneSignalUserID)
        }
        if let newAttributes {
            let stringifiedParams = stringifyParams(newAttributes)
            Purchases.shared.attribution.setAttributes(stringifiedParams)
        }
        PostHogSDK.shared.identify(id, userProperties: newAttributes)
        Purchases.shared.attribution.setPostHogUserID(id)
    }

    static func setUserAttribute(key: String, rawValue: String) {
        PostHogSDK.shared.register([key: rawValue])
        Purchases.shared.attribution.setAttributes([key: rawValue])
    }

    static func updateIncrementedAttribute(key: String, value: Double) {
        PostHogSDK.shared.register([key: value])
    }

    static func stringifyParams(_ params: [String: Any]) -> [String: String] {
        params.reduce(into: [:]) { partialResult, element in
            partialResult[element.key] = String(describing: element.value)
        }
    }
}

extension AnalyticsClient: DependencyKey {
    public static let liveValue: AnalyticsClient = .default()
}
