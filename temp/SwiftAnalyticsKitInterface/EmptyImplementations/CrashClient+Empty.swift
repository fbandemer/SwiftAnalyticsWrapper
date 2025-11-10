import Foundation
import OSLog

/// Logging-backed crash client with empty behavior.
public extension CrashClient {
    static let empty: Self = {
        let logger = Logger(subsystem: "SwiftAnalyticsKitInterface", category: "EmptyCrashClient")
        return Self(
            configuration: { .init() },
            start: { configuration in
                logger.debug("EmptyCrashClient.start(with:) invoked for environment \(configuration.environment, privacy: .public)")
            },
            capture: { error, attachments in
                logger.error("EmptyCrashClient.capture(error:attachments:) invoked: \(String(describing: error), privacy: .public) attachments: \(attachments.count.formatted())")
            },
            log: { message in
                logger.debug("EmptyCrashClient.log(_:) invoked with message \(message, privacy: .public)")
            }
        )
    }()
}
