// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  Analytics.swift
//  GroupSpend
//
//  Created by Fynn Bandemer on 28.10.23.
//

import Foundation
import TelemetryClient
import SuperwallKit
import OSLog
import Mixpanel
import RevenueCat
import PostHog

final public class Analytics {
    var logger: Logger = Logger(subsystem: "set subsystem", category: "set category")
    var userDefault: UserDefaults = .standard
    var userID: String? = nil
    var enrichment: (String?, Set<String>) = (nil, [])
    var attributes: [String: Any] = [:]
    var useMixpanel: Bool = false
    var useTelemetryDeck: Bool = false
    var useSuperwall: Bool = false
    var usePosthog: Bool = false
    var useSentry: Bool = false
    
    public static let shared = Analytics()
    
    public func initialize(
        for userID: String?,
        with logger: Logger,
        superwallID: String?,
        posthogAPIKey: String?,
        telemetryID: String?,
        mixpanelID: String?,
        sentry: String?,
        revenueCatID: String?,
        userDefault: UserDefaults
    ) {
        self.logger = logger
        self.userID = userID
        self.userDefault = userDefault
        if let mixpanelID {
            useMixpanel = true
            let mixpanel = Mixpanel.initialize(token: mixpanelID, trackAutomaticEvents: true)
            mixpanel.serverURL = "https://api-eu.mixpanel.com"
            if let userID {
                Mixpanel.mainInstance().identify(distinctId: userID)
            }
        }
        if let telemetryID {
            useTelemetryDeck = true
            let configuration = TelemetryManagerConfiguration(
                        appID: telemetryID)
            configuration.defaultUser = userID
            TelemetryManager.initialize(with: configuration)
        }
        
        if let posthogAPIKey {
            usePosthog = true
            let host = "https://eu.i.posthog.com"
            let config = PostHogConfig(apiKey: posthogAPIKey, host: host)
            config.sessionReplay = true
            config.captureElementInteractions = false
            config.sessionReplayConfig.screenshotMode = true
            config.sessionReplayConfig.maskAllTextInputs = false
            config.sessionReplayConfig.maskAllImages = false
            config.personProfiles = .identifiedOnly
            #if DEBUG
            config.debug = true
            #endif
            PostHogSDK.shared.setup(config)
            if let userID {
//                PostHogSDK.shared.getAnonymousId()
                PostHogSDK.shared.identify(userID)
            }
        }
        
        if let revenueCatID {
#if DEBUG
            Purchases.logLevel = .debug
#endif
            Purchases.configure(withAPIKey: revenueCatID, appUserID: userID)
            Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()

        }
        
        if let superwallID {
            useSuperwall = true
            if revenueCatID != nil {
                let purchaseController = RCPurchaseController(userDefault: userDefault)
                Superwall.configure(apiKey: superwallID, purchaseController: purchaseController)
                purchaseController.syncSubscriptionStatus()
            } else {
                Superwall.configure(apiKey: superwallID)
            }
            let superwallService = SuperwallService(logger: logger, withTelemetry: useTelemetryDeck, withMixpanel: useMixpanel, withPostHog: usePosthog)
            Superwall.shared.delegate = superwallService
        }
        
        if let sentry {
            CrashManager.shared.start(id: sentry)
            useSentry = true
        }
    }
    

    
    public func time(event: String) {
        if useMixpanel {
            Mixpanel.mainInstance().time(event: event)
        }
    }
    
    public func setUserID(_ userID: String, email: String?, oneSignalUserID: String? = nil, attributes: [String: Any]?) {
        Purchases.shared.logIn(userID) { (customerInfo, created, error) in
        }
        if let email {
            Purchases.shared.attribution.setEmail(email)
        }
        if let attributes = attributes {
            let stringifiedParams = stringifyParams(params: attributes)
            Purchases.shared.attribution.setAttributes(stringifiedParams)
        }
        if useMixpanel {
            Mixpanel.mainInstance().identify(distinctId: userID)
            Purchases.shared.attribution.setMixpanelDistinctID(userID)
            if let attributes = attributes {
                let stringifiedParams = stringifyParams(params: attributes)
                stringifiedParams.forEach({ Mixpanel.mainInstance().people.set(property: $0.key, to: $0.value )})

            }
        }
        if usePosthog {
            PostHogSDK.shared.identify(userID, userProperties: attributes)
            Purchases.shared.attribution.setPostHogUserID(userID)
        }
        if useTelemetryDeck {
            TelemetryManager.shared.updateDefaultUser(to: userID)
        }
        if useSuperwall {
            Superwall.shared.identify(userId: userID)
            if let attributes = attributes {
                Superwall.shared.setUserAttributes(attributes)
            }
        }
    }
    
    public func track(event: String, floatValue: Double? = nil, params: [String: Any]) {
        let stringifiedParams = stringifyParams(params: params)
        if useMixpanel {
            Mixpanel.mainInstance().track(event: event, properties: stringifiedParams)
        }
        if usePosthog {
            PostHogSDK.shared.capture(event, properties: params)
        }
        
        if useTelemetryDeck {
            let payload = enrichParams(params: params)
            let stringifiedPayload = stringifyParams(params: payload)
            TelemetryManager.shared.send(event, for: userID, floatValue: floatValue, with: stringifiedPayload)
            if useMixpanel {
                Purchases.shared.attribution.setMixpanelDistinctID(Mixpanel.mainInstance().distinctId)
            }
        }
        if useSentry {
            CrashManager.shared.log("Event logged: \(event)")
        }
        logger.log("Event logged: \(event)")
    }

    public func setUserAttributes(key: String, value: String) {
        if useMixpanel {
            Mixpanel.mainInstance().people.set(property: key, to: value)
        }
        if usePosthog {
            PostHogSDK.shared.register([key: value])
        }
        if let number = Double(value) {
            userDefault.set(number, forKey:key)
        } else {
            userDefault.set(value, forKey: key)
        }
        attributes[key] = value
        Superwall.shared.setUserAttributes(attributes)
    }
    
    public func incrementAttribute(key: String, value: Double) {
        if useMixpanel {
            Mixpanel.mainInstance().people.increment(property: key, by: value)
        }
        if usePosthog {
            PostHogSDK.shared.register([key: value])
        }
        let oldValue = userDefault.double(forKey: key)
        let newValue = value + oldValue
        attributes[key] = newValue
        userDefault.set(newValue, forKey:key)
        Superwall.shared.setUserAttributes(attributes)
    }
    
    public func setSubscriptionStatus(active: Bool, key: String) {
        setUserAttributes(key: key, value: "\(active)")
    }
    
    public func setUserID(userID: String) {
        self.userID = userID
        if useMixpanel {
            Mixpanel.mainInstance().identify(distinctId: userID)
        }
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
    
    
    public func setRCAttributionConsent() {
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
    }
    
    private func enrichParams(params: [String: Any]) -> [String: Any] {
        return attributes.merging(params) { _, new in new }
    }
    
    public func restorePurchases() async throws -> CustomerInfo {
        let customerInfos = try await Purchases.shared.restorePurchases()
        return customerInfos
    }
}


//extension Analytics  {
//}

