//
//  SuperwallService.swift
//
//  Created by Fynn Bandemer on 04.11.23.
//

#if canImport(SuperwallKit)
    import Foundation
    import OSLog
    import PostHog
    import SuperwallKit

    class SuperwallService: SuperwallDelegate {
        let logger: Logger

        init(logger: Logger) {
            self.logger = logger
        }

        func handleSuperwallPlacement(withInfo placementInfo: SuperwallPlacementInfo) {
            PostHogSDK.shared.capture(placementInfo.placement.description, properties: placementInfo.params)
            logger.log("Superwall Event logged: \(placementInfo.placement.description)")
        }
    }
#endif
