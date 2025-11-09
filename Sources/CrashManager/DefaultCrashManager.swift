//
//  File.swift
//  
//
//  Created by Fynn Bandemer on 07.11.23.
//

import CrashManagerInterface
import Foundation
import Observation
import Sentry

/// Default crash manager backed by Sentry.
@Observable
public final class DefaultCrashManager: CrashManagerInterface.CrashManager {
    public nonisolated(unsafe) static let shared = DefaultCrashManager()

    public override func start(with configuration: CrashConfiguration) {
        super.start(with: configuration)

        guard let dsn = configuration.dsn else {
            assertionFailure("CrashConfiguration missing DSN while attempting to start crash manager.")
            return
        }

        SentrySDK.start { options in
            options.dsn = dsn
            options.environment = configuration.environment
            #if os(iOS)
            options.attachScreenshot = configuration.enableScreenshots
            #endif
        }
    }

    /// Backwards-compatible convenience that infers the environment from the build configuration.
    public func start(id: String) {
        start(with: CrashConfiguration(dsn: id, environment: Self.defaultEnvironment))
    }

    public override func capture(error: Error, attachments: [CrashAttachment] = []) {
        guard !attachments.isEmpty else {
            SentrySDK.capture(error: error)
            return
        }

        SentrySDK.capture(error: error) { scope in
            attachments.forEach { attachment in
                let sentryAttachment = Attachment(data: attachment.data, filename: attachment.filename, contentType: attachment.contentType)
                scope.add(sentryAttachment)
            }
        }
    }

    public override func log(_ message: String) {
        let crumb = Breadcrumb()
        crumb.level = .info
        crumb.category = "log"
        crumb.message = message
        SentrySDK.addBreadcrumb(crumb)
    }

    private static var defaultEnvironment: String {
        #if DEBUG
        return "development"
        #else
        return "production"
        #endif
    }
}
