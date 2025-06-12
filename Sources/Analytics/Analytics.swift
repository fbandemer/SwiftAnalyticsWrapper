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
import AnalyticsCore

final public class Analytics: AnalyticsManager {
    public var configuration: AnalyticsConfiguration
    public var logger: Logger
    var userDefault: UserDefaults = .standard
    var userID: String? = nil
    var attributes: [String: Any] = [:]
    var useMixpanel: Bool = false
    var useTelemetryDeck: Bool = false
    var useSuperwall: Bool = false
    var usePosthog: Bool = false
    var useSentry: Bool = false
    
    public static let shared = Analytics()
    
    private init() {
        self.configuration = AnalyticsConfiguration()
        self.logger = configuration.logger
        self.userDefault = configuration.userDefaults
    }
    
    public func initialize(with configuration: AnalyticsConfiguration) {
        self.configuration = configuration
        self.logger = configuration.logger
        self.userID = configuration.userID
        self.userDefault = configuration.userDefaults
        
        if let mixpanelID = configuration.mixpanelID {
            useMixpanel = true
            let mixpanel = Mixpanel.initialize(token: mixpanelID, trackAutomaticEvents: true)
            mixpanel.serverURL = "https://api-eu.mixpanel.com"
            if let userID = configuration.userID {
                Mixpanel.mainInstance().identify(distinctId: userID)
            }
        }
        
        if let telemetryID = configuration.telemetryID {
            useTelemetryDeck = true
            let telemetryConfig = TelemetryManagerConfiguration(appID: telemetryID)
            telemetryConfig.defaultUser = configuration.userID
            TelemetryManager.initialize(with: telemetryConfig)
        }
        
        if let posthogAPIKey = configuration.posthogAPIKey {
            usePosthog = true
            let host = "https://eu.i.posthog.com"
            let config = PostHogConfig(apiKey: posthogAPIKey, host: host)
            config.sessionReplay = true
            config.captureElementInteractions = false
            config.sessionReplayConfig.screenshotMode = true
            config.sessionReplayConfig.maskAllTextInputs = false
            config.sessionReplayConfig.maskAllImages = false
            #if DEBUG
            config.debug = true
            #endif
            PostHogSDK.shared.setup(config)
            if let userID = configuration.userID {
                PostHogSDK.shared.identify(userID)
            }
        }
        
        if let revenueCatID = configuration.revenueCatID {
            #if DEBUG
            Purchases.logLevel = .debug
            #endif
            Purchases.configure(withAPIKey: revenueCatID, appUserID: configuration.userID)
            Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
        }
        
        if let superwallID = configuration.superwallID {
            useSuperwall = true
            if configuration.revenueCatID != nil {
                let purchaseController = RCPurchaseController(userDefault: configuration.userDefaults)
                Superwall.configure(apiKey: superwallID, purchaseController: purchaseController)
                purchaseController.syncSubscriptionStatus()
            } else {
                Superwall.configure(apiKey: superwallID)
            }
            let superwallService = SuperwallService(
                logger: configuration.logger, 
                withTelemetry: useTelemetryDeck, 
                withMixpanel: useMixpanel, 
                withPostHog: usePosthog
            )
            Superwall.shared.delegate = superwallService
        }
        
        if let sentryDSN = configuration.sentryDSN {
            CrashManager.shared.start(id: sentryDSN)
            useSentry = true
        }
    }
    
    public func time(event: String) {
        if useMixpanel {
            Mixpanel.mainInstance().time(event: event)
        }
    }
    
    public func setUserID(_ userID: String, attributes: [String: Any]? = nil) {
        self.userID = userID
        
        if useMixpanel {
            Mixpanel.mainInstance().identify(distinctId: userID)
            if let attributes = attributes {
                let stringifiedParams = StringifyUtility.stringifyParams(params: attributes)
                stringifiedParams.forEach({ Mixpanel.mainInstance().people.set(property: $0.key, to: $0.value )})
            }
        }
        
        if usePosthog {
            PostHogSDK.shared.identify(userID, userProperties: attributes)
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
        
        Purchases.shared.logIn(userID) { (customerInfo, created, error) in }
        
        if let attributes = attributes {
            let stringifiedParams = StringifyUtility.stringifyParams(params: attributes)
            Purchases.shared.attribution.setAttributes(stringifiedParams)
        }
    }
    
    public func track(event: AnalyticsEvent) {
        track(event: event.name, floatValue: event.value, params: event.parameters)
    }
    
    public func track(event: String, floatValue: Double? = nil, params: [String: Any]) {
        let stringifiedParams = StringifyUtility.stringifyParams(params: params)
        
        if useMixpanel {
            Mixpanel.mainInstance().track(event: event, properties: stringifiedParams)
        }
        
        if usePosthog {
            PostHogSDK.shared.capture(event, properties: params)
        }
        
        if useTelemetryDeck {
            let payload = StringifyUtility.enrichParams(baseAttributes: attributes, additionalParams: params)
            let stringifiedPayload = StringifyUtility.stringifyParams(params: payload)
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

    public func setUserAttribute(key: String, value: String) {
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
        
        if useSuperwall {
            Superwall.shared.setUserAttributes(attributes)
        }
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
        
        if useSuperwall {
            Superwall.shared.setUserAttributes(attributes)
        }
    }
    
    public func setSubscriptionStatus(active: Bool, key: String) {
        setUserAttribute(key: key, value: "\(active)")
    }
    
    public func setRCAttributionConsent() {
        Purchases.shared.attribution.enableAdServicesAttributionTokenCollection()
    }
    
    public func restorePurchases() async throws -> CustomerInfo {
        let customerInfos = try await Purchases.shared.restorePurchases()
        return customerInfos
    }
    
    // Legacy method for backward compatibility
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
        let config = AnalyticsConfiguration(
            userID: userID,
            logger: logger,
            superwallID: superwallID,
            posthogAPIKey: posthogAPIKey,
            telemetryID: telemetryID,
            mixpanelID: mixpanelID,
            sentryDSN: sentry,
            revenueCatID: revenueCatID,
            userDefaults: userDefault
        )
        initialize(with: config)
    }
    
    // Legacy method for backward compatibility
    public func setUserAttributes(key: String, value: String) {
        setUserAttribute(key: key, value: value)
    }
    
    // Legacy method for backward compatibility
    public func setUserID(userID: String) {
        setUserID(userID, attributes: nil)
    }
}

