import Dependencies
import Foundation
import OSLog
import PostHog
import RevenueCat
import SwiftAnalyticsKitInterface
import SwiftUI
#if canImport(SuperwallKit)
import SuperwallKit
#endif

private enum AnalyticsClientDefaults {
    static let subsystem = "Analytics"
    static let category = "Default"
    static let posthogHost = "https://eu.i.posthog.com"
}

public extension AnalyticsClient {
    static func `default`() -> Self {
        var configuration = AnalyticsConfiguration()
        var logger = Logger(subsystem: AnalyticsClientDefaults.subsystem, category: AnalyticsClientDefaults.category)
        var userDefaults = UserDefaults.standard
        var userID: String?
        var attributes: [String: Any] = [:]
        var useSuperwall = false
        var usePosthog = false

        func stringifyParams(_ params: [String: Any]) -> [String: String] {
            var stringified: [String: String] = [:]
            for (key, value) in params {
                stringified[key] = String(describing: value)
            }
            return stringified
        }

        func trackEvent(named name: String, params: [String: Any]) {
            if usePosthog {
                PostHogSDK.shared.capture(name, properties: params)
            }

            logger.log("Event logged: \(name, privacy: .public)")
        }

        func setUserAttributeValue(_ key: String, _ value: String) {
            if usePosthog {
                PostHogSDK.shared.register([key: value])
            }

            if let number = Double(value) {
                userDefaults.set(number, forKey: key)
            } else {
                userDefaults.set(value, forKey: key)
            }

            attributes[key] = value

            #if canImport(SuperwallKit)
                if useSuperwall {
                    Superwall.shared.setUserAttributes(attributes)
                }
            #endif
        }

        func incrementAttributeValue(_ key: String, by value: Double) {
            if usePosthog {
                PostHogSDK.shared.register([key: value])
            }

            let oldValue = userDefaults.double(forKey: key)
            let newValue = value + oldValue
            attributes[key] = newValue
            userDefaults.set(newValue, forKey: key)

            #if canImport(SuperwallKit)
                if useSuperwall {
                    Superwall.shared.setUserAttributes(attributes)
                }
            #endif
        }

        func assignUser(
            id: String,
            email: String?,
            oneSignalUserID: String?,
            attributes newAttributes: [String: Any]?
        ) {
            userID = id
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

            if usePosthog {
                PostHogSDK.shared.identify(id, userProperties: newAttributes)
                Purchases.shared.attribution.setPostHogUserID(id)
            }

            #if canImport(SuperwallKit)
                if useSuperwall {
                    Superwall.shared.identify(userId: id)
                    if let newAttributes {
                        Superwall.shared.setUserAttributes(newAttributes)
                    }
                }
            #endif
        }

        func handlePlacement(
            _ placement: String,
            params: [String: Any],
            completion: @escaping AnalyticsAction
        ) {
            #if canImport(SuperwallKit)
                if useSuperwall {
                    Superwall.shared.register(placement: placement, params: params) {
                        completion()
                    }
                    return
                }
            #endif
            completion()
        }

        return Self(
            configuration: { configuration },
            isSuperwallEnabled: {
                #if canImport(SuperwallKit)
                    return useSuperwall
                #else
                    return false
                #endif
            },
            configure: { newConfiguration in
                configuration = newConfiguration

                let subsystem = newConfiguration.loggerSubsystem.isEmpty ? AnalyticsClientDefaults.subsystem : newConfiguration.loggerSubsystem
                let category = newConfiguration.loggerCategory.isEmpty ? AnalyticsClientDefaults.category : newConfiguration.loggerCategory
                logger = Logger(subsystem: subsystem, category: category)
                usePosthog = false
                useSuperwall = false

                if let posthogAPIKey = newConfiguration.posthogAPIKey {
                    usePosthog = true
                    var posthogConfig = PostHogConfig(apiKey: posthogAPIKey, host: AnalyticsClientDefaults.posthogHost)

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
                    if let userID {
                        PostHogSDK.shared.identify(userID)
                    }
                }

                if let revenueCatID = newConfiguration.revenueCatAPIKey {
                    #if DEBUG
                        Purchases.logLevel = .debug
                    #endif
                    Purchases.configure(withAPIKey: revenueCatID, appUserID: userID)
                    Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
                }

                #if canImport(SuperwallKit)
                    if let superwallID = newConfiguration.superwallAPIKey {
                        useSuperwall = true
                        if newConfiguration.revenueCatAPIKey != nil {
                            let purchaseController = RCPurchaseController(userDefault: userDefaults)
                            Superwall.configure(apiKey: superwallID, purchaseController: purchaseController)
                            purchaseController.syncSubscriptionStatus()
                        } else {
                            Superwall.configure(apiKey: superwallID)
                        }
                        let superwallService = SuperwallService(logger: logger, withPostHog: usePosthog)
                        Superwall.shared.delegate = superwallService
                    } else {
                        useSuperwall = false
                    }
                #else
                    if newConfiguration.superwallAPIKey != nil {
                        logger.log("Superwall ID provided but Superwall is unavailable on this platform.")
                    }
                #endif
            },
            initializeIfNeeded: { defaults in
                userDefaults = defaults
            },
            track: { event in
                trackEvent(named: event.name, params: event.properties.toAnyDictionary())
            },
            setUserIdentity: { identity in
                assignUser(
                    id: identity.id,
                    email: identity.email,
                    oneSignalUserID: identity.pushToken,
                    attributes: identity.attributes.toAnyDictionary()
                )
            },
            setUserAttribute: { key, value in
                setUserAttributeValue(key, String(describing: value.anyValue))
            },
            incrementUserAttribute: { key, value in
                incrementAttributeValue(key, by: value)
            },
            setSubscriptionStatus: { isActive, key in
                setUserAttributeValue(key, "\(isActive)")
            },
            handlePlacement: { placement, params, completion in
                handlePlacement(placement, params: params, completion: completion)
            },
            makeCustomerCenterView: {
                AnyView(CustomerCenterContainerView())
            }
        )
    }
}

extension AnalyticsClient: DependencyKey {
    public static let liveValue: AnalyticsClient = .default()
}
