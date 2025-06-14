//
//  File.swift
//  
//
//  Created by Fynn Bandemer on 07.11.23.
//

import Foundation
import SwiftUI
// TODO: Fix Sentry import issue
// import SentrySwiftUI

final public class CrashManager {
    public static let shared = CrashManager()
    
    public func start(id: String) {
        // TODO: Re-enable Sentry when import is fixed
        /*
        SentrySDK.start { options in
            options.dsn = id
//            options.debug = true
//            options.attachScreenshot = true // This property doesn't exist in current Sentry version
            // Enabled debug when first installing is always helpful
//            options.enableTracing = true
        }
        */
    }
    
    public func capture(error: Error) {
        // TODO: Re-enable Sentry when import is fixed
        // SentrySDK.capture(error: error)
    }
    
    public func log(_ message: String) {
        // TODO: Re-enable Sentry when import is fixed
        /*
        let crumb = Breadcrumb()
        crumb.level = SentryLevel.info
        crumb.category = "log"
        crumb.message = message
        SentrySDK.addBreadcrumb(crumb)
        */
    }
}
