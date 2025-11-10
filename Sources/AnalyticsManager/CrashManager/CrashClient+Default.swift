import Dependencies
import Foundation
import Sentry
import SwiftAnalyticsKitInterface

private enum CrashClientDefaults {
    #if DEBUG
        static let environment = "development"
    #else
        static let environment = "production"
    #endif
}

public extension CrashClient {
    static func sentry() -> Self {
        return Self(
            configuration: { CrashConfiguration() },
            start: { newConfiguration in
                guard let dsn = newConfiguration.dsn else {
                    return
                }

                SentrySDK.start { options in
                    options.dsn = dsn
                    options.environment = newConfiguration.environment
                    #if os(iOS)
                        options.attachScreenshot = newConfiguration.enableScreenshots
                    #endif
                }
            },
            capture: { error, attachments in
                guard !attachments.isEmpty else {
                    SentrySDK.capture(error: error)
                    return
                }

                SentrySDK.capture(error: error) { scope in
                    for attachment in attachments {
                        let sentryAttachment = Attachment(
                            data: attachment.data,
                            filename: attachment.filename,
                            contentType: attachment.contentType
                        )
                        scope.add(sentryAttachment)
                    }
                }
            },
            log: { message in
                let crumb = Breadcrumb()
                crumb.level = .info
                crumb.category = "log"
                crumb.message = message
                SentrySDK.addBreadcrumb(crumb)
            }
        )
    }

    // func start(dsn: String) {
    //     start(
    //         CrashConfiguration(
    //             dsn: dsn,
    //             environment: CrashClientDefaults.environment
    //         )
    //     )
    // }
}

extension CrashClient: DependencyKey {
    public static let liveValue: CrashClient = .sentry()
}
