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
#if os(iOS)
import SuperwallKit
#endif
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
    
    /// Creates an Analytics instance with an optional ID. If left empty defaults to UUID
    public init() {
        enrichment.0 = UUID().uuidString
    }
    
    /// You are required to call start() before any tracking takes place
    public func start(userID: String? = nil, superwall: String? = nil, mixpanelID: String? = nil, telemetryId: String? = nil, posthogAPIKey: String? = nil, sentryId: String? = nil, revenueCatAPIKey: String? = nil, userDefault: UserDefaults = .standard, logger: Logger = Logger(subsystem: "set subsystem", category: "set category")) {
        self.userDefault = userDefault
        self.logger = logger
        
        logger.log("Starting Analytics")
        
        self.userID = userID
        
        enrichment.1.insert("is_devoloper")
        
        if let mixpanelID {
            useMixpanel = true
            let mixpanel = Mixpanel.initialize(token: mixpanelID, trackAutomaticEvents: true)
            mixpanel.serverURL = "https://api-eu.mixpanel.com"
            if let userID {
                mixpanel.identify(distinctId: userID)
            }
        }
        
        if let telemetryId {
            useTelemetryDeck = true
            TelemetryManager.initialize(with: TelemetryManagerConfiguration(appID: telemetryId))
            if let userID {
                TelemetryManager.send("set_user", with: ["user_id": userID])
            }
        }
        
        if let posthogAPIKey {
            usePosthog = true
            let host = "https://eu.i.posthog.com"
            let config = PostHogConfig(apiKey: posthogAPIKey, host: host)
            // TODO: These properties might not exist in current PostHog version
            // config.sessionReplay = true
            // config.captureElementInteractions = false
            // config.sessionReplayConfig.screenshotMode = true
            // config.sessionReplayConfig.maskAllTextInputs = false
            // config.sessionReplayConfig.maskAllImages = false
            #if DEBUG
            config.debug = true
            #endif
            PostHogSDK.shared.setup(config)
            if let userID {
                PostHogSDK.shared.identify(userID)
            }
        }
        
        if let sentryId {
            useSentry = true
            CrashManager.shared.start(id: sentryId)
        }
        
        #if os(iOS)
        if let superwall {
            useSuperwall = true
            let superwallService = SuperwallService(logger: logger, withTelemetry: useTelemetryDeck, withMixpanel: useMixpanel, withPostHog: usePosthog)
            Superwall.configure(apiKey: superwall, purchaseController: RCPurchaseController(userDefault: userDefault))
            Superwall.shared.delegate = superwallService
        }
        #endif
        
        if let revenueCatAPIKey {
            Purchases.logLevel = .warn
            Purchases.configure(withAPIKey: revenueCatAPIKey)
            
            if let userID {
                Purchases.shared.logIn(userID) { customerInfo, created, error in
                    if let error {
                        self.logger.error("Error when logging into revenue cat: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        logger.log("Started Analytics")
    }
    
    public func time(event: String) {
        if useMixpanel {
            Mixpanel.mainInstance().time(event: event)
        }
    }
    
    public func setUserID(_ userID: String, attributes: [String: Any]?) {
        if useMixpanel {
            Mixpanel.mainInstance().identify(distinctId: userID)
            if let attributes = attributes {
                let stringifiedParams = stringifyParams(params: attributes)
                stringifiedParams.forEach({ Mixpanel.mainInstance().people.set(property: $0.key, to: $0.value )})

            }
        }
        if usePosthog {
            PostHogSDK.shared.identify(userID, userProperties: attributes)
        }
        if useTelemetryDeck {
            TelemetryManager.shared.updateDefaultUser(to: userID)
        }
        #if os(iOS)
        if useSuperwall {
            Superwall.shared.identify(userId: userID)
            if let attributes = attributes {
                Superwall.shared.setUserAttributes(attributes)
            }
        }
        #endif
        Purchases.shared.logIn(userID) { (customerInfo, created, error) in
        }
        if let attributes = attributes {
            let stringifiedParams = stringifyParams(params: attributes)
            Purchases.shared.attribution.setAttributes(stringifiedParams)
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
        #if os(iOS)
        Superwall.shared.setUserAttributes(attributes)
        #endif
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
        #if os(iOS)
        Superwall.shared.setUserAttributes(attributes)
        #endif
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

