//
//  File.swift
//  
//
//  Created by Fynn Bandemer on 07.11.23.
//

import Foundation
import SwiftUI
import Sentry

final public class CrashManager {
    public static let shared = CrashManager()
    
    public func start(id: String) {
        SentrySDK.start { options in
            #if DEBUG
            options.environment = "development"
            #endif
            options.dsn = id
//            options.debug = true
            options.attachScreenshot = true
            // Enabled debug when first installing is always helpful
//            options.enableTracing = true
        }
    }
    
    public func capture(error: Error) {
        SentrySDK.capture(error: error)
    }
    
    public func log(_ message: String) {
        let crumb = Breadcrumb()
        crumb.level = SentryLevel.info
        crumb.category = "log"
        crumb.message = message
        SentrySDK.addBreadcrumb(crumb)
    }
}
