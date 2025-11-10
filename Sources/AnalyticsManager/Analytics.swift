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

private struct AnalyticsRuntime {
    var configuration = AnalyticsConfiguration()
    var logger = Logger(subsystem: AnalyticsClientDefaults.subsystem, category: AnalyticsClientDefaults.category)
    var userDefaults = UserDefaults.standard
    var userID: String?
    var attributes: [String: Any] = [:]
    var useSuperwall = false
    var usePosthog = false

    var isSuperwallEnabled: Bool {
        #if canImport(SuperwallKit)
            return useSuperwall
        #else
            return false
        #endif
    }

    mutating func configure(using newConfiguration: AnalyticsConfiguration) {
        configuration = newConfiguration

        let subsystem = newConfiguration.loggerSubsystem.isEmpty ? AnalyticsClientDefaults.subsystem : newConfiguration.loggerSubsystem
        let category = newConfiguration.loggerCategory.isEmpty ? AnalyticsClientDefaults.category : newConfiguration.loggerCategory
        logger = Logger(subsystem: subsystem, category: category)
        usePosthog = false
        useSuperwall = false

        if let posthogAPIKey = newConfiguration.posthogAPIKey {
            configurePosthog(apiKey: posthogAPIKey)
        }

        if let revenueCatID = newConfiguration.revenueCatAPIKey {
            configureRevenueCat(apiKey: revenueCatID)
        }

        #if canImport(SuperwallKit)
            if let superwallID = newConfiguration.superwallAPIKey {
                configureSuperwall(apiKey: superwallID, revenueCatEnabled: newConfiguration.revenueCatAPIKey != nil)
            } else {
                useSuperwall = false
            }
        #else
            if newConfiguration.superwallAPIKey != nil {
                logger.log("Superwall ID provided but Superwall is unavailable on this platform.")
            }
        #endif
    }

    mutating func initializeIfNeeded(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    mutating func track(_ event: AnalyticsEvent) {
        track(name: event.name, params: event.properties.toAnyDictionary())
    }

    mutating func setUserIdentity(_ identity: AnalyticsUserIdentity) {
        assignUser(
            id: identity.id,
            email: identity.email,
            oneSignalUserID: identity.pushToken,
            attributes: identity.attributes.toAnyDictionary()
        )
    }

    mutating func setUserAttribute(key: String, value: AnalyticsAttributeValue) {
        setUserAttribute(key: key, rawValue: String(describing: value.anyValue))
    }

    mutating func incrementUserAttribute(key: String, value: Double) {
        updateIncrementedAttribute(key: key, value: value)
    }

    mutating func setSubscriptionStatus(isActive: Bool, key: String) {
        setUserAttribute(key: key, rawValue: "\(isActive)")
    }

    func handlePlacement(_ placement: String, params: [String: Any], completion: @escaping AnalyticsAction) {
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

    func makeCustomerCenterView() -> AnyView {
        AnyView(CustomerCenterContainerView())
    }

    // MARK: - Private helpers

    private mutating func configurePosthog(apiKey: String) {
        usePosthog = true
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
        if let userID {
            PostHogSDK.shared.identify(userID)
        }
    }

    private mutating func configureRevenueCat(apiKey: String) {
        #if DEBUG
            Purchases.logLevel = .debug
        #endif
        Purchases.configure(withAPIKey: apiKey, appUserID: userID)
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
    }

    #if canImport(SuperwallKit)
        private mutating func configureSuperwall(apiKey: String, revenueCatEnabled: Bool) {
            useSuperwall = true
            if revenueCatEnabled {
                let purchaseController = RCPurchaseController(userDefault: userDefaults)
                Superwall.configure(apiKey: apiKey, purchaseController: purchaseController)
                purchaseController.syncSubscriptionStatus()
            } else {
                Superwall.configure(apiKey: apiKey)
            }
            let superwallService = SuperwallService(logger: logger, withPostHog: usePosthog)
            Superwall.shared.delegate = superwallService
        }
    #endif

    private func track(name: String, params: [String: Any]) {
        if usePosthog {
            PostHogSDK.shared.capture(name, properties: params)
        }

        PostHogSDK.shared.capture(name, properties: params)
        logger.log("Event logged: \(name, privacy: .public)")
    }

    private mutating func setUserAttribute(key: String, rawValue: String) {
        if usePosthog {
            PostHogSDK.shared.register([key: rawValue])
        }

        if let number = Double(rawValue) {
            userDefaults.set(number, forKey: key)
        } else {
            userDefaults.set(rawValue, forKey: key)
        }

        attributes[key] = rawValue

        #if canImport(SuperwallKit)
            if useSuperwall {
                Superwall.shared.setUserAttributes(attributes)
            }
        #endif
    }

    private mutating func updateIncrementedAttribute(key: String, value: Double) {
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

    private func stringifyParams(_ params: [String: Any]) -> [String: String] {
        params.reduce(into: [:]) { partialResult, element in
            partialResult[element.key] = String(describing: element.value)
        }
    }

    private mutating func assignUser(
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
}

public extension AnalyticsClient {
    static func `default`() -> Self {
        var runtime = AnalyticsRuntime() // no such Dependencies

        return Self(
            configuration: { runtime.configuration },
            isSuperwallEnabled: { runtime.isSuperwallEnabled },
            configure: { runtime.configure(using: $0) },
            initializeIfNeeded: { runtime.initializeIfNeeded(userDefaults: $0) },
            track: { event in // this is the way to implement
                PostHogSDK.shared.capture(event.name, properties: event.properties.toAnyDictionary())
                logger.log("Event logged: \(event.name, privacy: .public)")
            },
            setUserIdentity: { runtime.setUserIdentity($0) },
            setUserAttribute: { runtime.setUserAttribute(key: $0, value: $1) },
            incrementUserAttribute: { runtime.incrementUserAttribute(key: $0, value: $1) },
            setSubscriptionStatus: { runtime.setSubscriptionStatus(isActive: $0, key: $1) },
            handlePlacement: { runtime.handlePlacement($0, params: $1, completion: $2) },
            makeCustomerCenterView: { runtime.makeCustomerCenterView() }
        )
    }
}

extension AnalyticsClient: DependencyKey {
    public static let liveValue: AnalyticsClient = .default()
}
