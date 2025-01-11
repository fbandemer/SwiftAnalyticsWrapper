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

internal class SuperwallService: SuperwallDelegate {
    let logger: Logger
    let telemetry: Bool
    let mixpanel: Bool
    
    internal init(logger: Logger, withTelemetry: Bool, withMixpanel: Bool) {
        self.logger = logger
        self.telemetry = withTelemetry
        self.mixpanel = withMixpanel
    }
    
    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        var stringifiedParams: [String: String] = [:]
        for param in eventInfo.params {
            stringifiedParams[param.key] = String(describing: param.value)
        }
        if telemetry { TelemetryManager.send(eventInfo.event.description, with: stringifiedParams) }
        if mixpanel { Mixpanel.mainInstance().track(event: eventInfo.event.description, properties: stringifiedParams) }
        logger.log("Superwall Event logged: \(eventInfo.event.description)")
    }
}
