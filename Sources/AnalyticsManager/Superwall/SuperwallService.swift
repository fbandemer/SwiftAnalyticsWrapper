//
//  File.swift
//
//  Created by Fynn Bandemer on 04.11.23.
//

#if canImport(SuperwallKit)
import Foundation
import SuperwallKit
import OSLog
import PostHog

internal class SuperwallService: SuperwallDelegate {
    let logger: Logger
    let posthog: Bool
    
    internal init(logger: Logger, withPostHog: Bool) {
        self.logger = logger
        self.posthog = withPostHog
    }
    
    func handleSuperwallPlacement(withInfo placementInfo: SuperwallPlacementInfo) {
        if posthog {
            PostHogSDK.shared.capture(placementInfo.placement.description, properties: placementInfo.params)
        }
        logger.log("Superwall Event logged: \(placementInfo.placement.description)")
    }
}
#endif

