// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  Analytics.swift
//  GroupSpend
//
//  Created by Fynn Bandemer on 28.10.23.
//

import AnalyticsManagerInterface
import Foundation
import Observation
#if canImport(SuperwallKit)
import SuperwallKit
#endif
import OSLog
import RevenueCat
import PostHog

@Observable
public final class DefaultAnalyticsManager: AnalyticsManaging {
    public private(set) var configuration: AnalyticsConfiguration
    var logger: Logger = Logger(subsystem: "Analytics", category: "Default")
    var userDefault: UserDefaults = .standard
    var userID: String? = nil
    var attributes: [String: Any] = [:]
    var useSuperwall: Bool = false
    var usePosthog: Bool = false
    private static let posthogHost = "https://eu.i.posthog.com"

    nonisolated(unsafe) public static let shared = DefaultAnalyticsManager()

    public init(configuration: AnalyticsConfiguration = .init()) {
        self.configuration = configuration
    }

    public var isSuperwallEnabled: Bool {
#if canImport(SuperwallKit)
        return useSuperwall
#else
        return false
#endif
    }

    public func configure(using configuration: AnalyticsConfiguration) {
        self.configuration = configuration

        let subsystem = configuration.loggerSubsystem.isEmpty ? "Analytics" : configuration.loggerSubsystem
        let category = configuration.loggerCategory.isEmpty ? "Default" : configuration.loggerCategory
        logger = Logger(subsystem: subsystem, category: category)
        usePosthog = false
        useSuperwall = false

        if let posthogAPIKey = configuration.posthogAPIKey {
            usePosthog = true
            let config = PostHogConfig(apiKey: posthogAPIKey, host: Self.posthogHost)

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
            if let userID {
                PostHogSDK.shared.identify(userID)
            }
        }

        if let revenueCatID = configuration.revenueCatAPIKey {
#if DEBUG
            Purchases.logLevel = .debug
#endif
            Purchases.configure(withAPIKey: revenueCatID, appUserID: userID)
            Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
        }

#if canImport(SuperwallKit)
        if let superwallID = configuration.superwallAPIKey {
            useSuperwall = true
            if configuration.revenueCatAPIKey != nil {
                let purchaseController = RCPurchaseController(userDefault: userDefault)
                Superwall.configure(apiKey: superwallID, purchaseController: purchaseController)
                purchaseController.syncSubscriptionStatus()
            } else {
                Superwall.configure(apiKey: superwallID)
            }
            let superwallService = SuperwallService(logger: logger, withPostHog: usePosthog)
            Superwall.shared.delegate = superwallService
        }
#else
        if configuration.superwallAPIKey != nil {
            logger.log("Superwall ID provided but Superwall is unavailable on this platform.")
        }
#endif
    }

    public func initializeIfNeeded(userDefaults: UserDefaults) {
        userDefault = userDefaults
    }
    
    public func setUserID(_ userID: String, email: String?, oneSignalUserID: String? = nil, attributes: [String: Any]?) {
        self.userID = userID
        Purchases.shared.logIn(userID) { (_, _, _) in
        }
        if let email {
            Purchases.shared.attribution.setEmail(email)
        }
        if let oneSignalUserID {
            Purchases.shared.attribution.setOnesignalUserID(oneSignalUserID)
        }
        
        if let attributes = attributes {
            let stringifiedParams = stringifyParams(params: attributes)
            Purchases.shared.attribution.setAttributes(stringifiedParams)
        }
        if usePosthog {
            PostHogSDK.shared.identify(userID, userProperties: attributes)
            Purchases.shared.attribution.setPostHogUserID(userID)
        }
#if canImport(SuperwallKit)
        if useSuperwall {
            Superwall.shared.identify(userId: userID)
            if let attributes = attributes {
                Superwall.shared.setUserAttributes(attributes)
            }
        }
#endif
    }
    
    public func track(_ event: AnalyticsEvent) {
        track(event: event.name, params: event.properties.toAnyDictionary())
    }

    /// High-level helper that encapsulates the previous SwiftUI button
    /// behavior. It validates event naming, tracks the event, and triggers the
    /// supplied action once analytics and any Superwall placement finish.
    public func performEvent(
        category: some AnalyticsCategory,
        object: AnalyticsObject,
        verb: AnalyticsVerb,
        attributes: AnalyticsAttributes = [:],
        action: @escaping AnalyticsAction
    ) {
        guard let event = try? AnalyticsEvent(
            category: category,
            object: object,
            verb: verb,
            properties: attributes
        ) else {
            assertionFailure("Invalid analytics naming for placement")
            return
        }

        track(event)
        handlePlacement(event.name, params: event.properties.toAnyDictionary()) {
            action()
        }
    }

    public func track(event: String, params: [String: Any]) {
        if usePosthog {
            PostHogSDK.shared.capture(event, properties: params)
        }
        
        logger.log("Event logged: \(event)")
    }

    public func setUserAttributes(key: String, value: String) {
        if usePosthog {
            PostHogSDK.shared.register([key: value])
        }
        if let number = Double(value) {
            userDefault.set(number, forKey:key)
        } else {
            userDefault.set(value, forKey: key)
        }
        attributes[key] = value
#if canImport(SuperwallKit)
        if useSuperwall {
            Superwall.shared.setUserAttributes(attributes)
        }
#endif
    }
    
    public func incrementAttribute(key: String, value: Double) {
        if usePosthog {
            PostHogSDK.shared.register([key: value])
        }
        let oldValue = userDefault.double(forKey: key)
        let newValue = value + oldValue
        attributes[key] = newValue
        userDefault.set(newValue, forKey:key)
#if canImport(SuperwallKit)
        if useSuperwall {
            Superwall.shared.setUserAttributes(attributes)
        }
#endif
    }
    
    public func setSubscriptionStatus(active: Bool, key: String) {
        setUserAttributes(key: key, value: "\(active)")
    }
    
    public func setUserID(userID: String) {
        self.userID = userID
        if usePosthog {
            PostHogSDK.shared.identify(userID)
        }
    }
    
    private func stringifyParams(params: [String: Any]) -> [String: String] {
        var stringifiedParams: [String: String] = [:]
        for param in params {
            stringifiedParams[param.key] = String(describing: param.value)
        }
        return stringifiedParams
    }

    public func setUserIdentity(_ identity: AnalyticsUserIdentity) {
        setUserID(identity.id, email: identity.email, attributes: identity.attributes.toAnyDictionary())
    }

    public func setUserAttribute(_ key: String, value: AnalyticsAttributeValue) {
        setUserAttributes(key: key, value: String(describing: value.anyValue))
    }

    public func incrementUserAttribute(_ key: String, by value: Double) {
        incrementAttribute(key: key, value: value)
    }

    public func setSubscriptionStatus(isActive: Bool, key: String) {
        setSubscriptionStatus(active: isActive, key: key)
    }

    public func handlePlacement(_ placement: String, params: [String: Any], completion: @escaping () -> Void) {
#if canImport(SuperwallKit)
        if isSuperwallEnabled {
            Superwall.shared.register(placement: placement, params: params) {
                completion()
            }
            return
        }
#endif
        completion()
    }

    public func setRCAttributionConsent() {
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
    }
    
    public func restorePurchases() async throws -> CustomerInfo {
        let customerInfos = try await Purchases.shared.restorePurchases()
        return customerInfos
    }
}
