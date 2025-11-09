//
//  File.swift
//
//
//  Created by Fynn Bandemer on 07.11.23.
//

import AnalyticsManagerInterface
import Foundation
import Observation
import Sentry

/// Default crash manager backed by Sentry.
@Observable
public final class DefaultCrashManager: CrashManaging {
    public nonisolated(unsafe) static let shared = DefaultCrashManager()

    public private(set) var configuration: CrashConfiguration

    public init(configuration: CrashConfiguration = .init()) {
        self.configuration = configuration
    }

    public func start(with configuration: CrashConfiguration) {
        self.configuration = configuration

        guard let dsn = configuration.dsn else { return }

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

    public func capture(error: Error, attachments: [CrashAttachment] = []) {
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

    public func log(_ message: String) {
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
