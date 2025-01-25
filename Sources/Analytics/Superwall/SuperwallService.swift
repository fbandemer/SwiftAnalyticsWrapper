//
//  File.swift
//  
//
//  Created by Fynn Bandemer on 04.11.23.
//

import Foundation
import SuperwallKit
import TelemetryClient
import Mixpanel
import OSLog
import PostHog

internal class SuperwallService: SuperwallDelegate {
    let logger: Logger
    let telemetry: Bool
    let mixpanel: Bool
    let posthog: Bool
    
    internal init(logger: Logger, withTelemetry: Bool, withMixpanel: Bool, withPostHog: Bool) {
        self.logger = logger
        self.telemetry = withTelemetry
        self.mixpanel = withMixpanel
        self.posthog = withPostHog
    }
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        var stringifiedParams: [String: String] = [:]
        for param in eventInfo.params {
            stringifiedParams[param.key] = String(describing: param.value)
        }
        if telemetry { TelemetryManager.send(eventInfo.event.description, with: stringifiedParams) }
        if mixpanel { Mixpanel.mainInstance().track(event: eventInfo.event.description, properties: stringifiedParams) }
        if posthog { PostHogSDK.shared.capture(eventInfo.event.description, properties: eventInfo.params) }
        logger.log("Superwall Event logged: \(eventInfo.event.description)")
    }
}
