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
    
    func handleSuperwallPlacement(withInfo placementInfo: SuperwallPlacementInfo) {
        var stringifiedParams: [String: String] = [:]
        for param in placementInfo.params {
            stringifiedParams[param.key] = String(describing: param.value)
        }
        if telemetry { TelemetryManager.send(placementInfo.placement.description, with: stringifiedParams) }
        if mixpanel { Mixpanel.mainInstance().track(event: placementInfo.placement.description, properties: stringifiedParams) }
        if posthog { PostHogSDK.shared.capture(placementInfo.placement.description, properties: placementInfo.params) }
        logger.log("Superwall Event logged: \(placementInfo.placement.description)")
    }
}
