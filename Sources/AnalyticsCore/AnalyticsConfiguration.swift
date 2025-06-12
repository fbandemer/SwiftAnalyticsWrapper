import Foundation
import OSLog

public struct AnalyticsConfiguration {
    public let userID: String?
    public let logger: Logger
    public let superwallID: String?
    public let posthogAPIKey: String?
    public let telemetryID: String?
    public let mixpanelID: String?
    public let sentryDSN: String?
    public let revenueCatID: String?
    public let userDefaults: UserDefaults
    
    public init(
        userID: String? = nil,
        logger: Logger = Logger(subsystem: "com.swiftanalyticswrapper", category: "analytics"),
        superwallID: String? = nil,
        posthogAPIKey: String? = nil,
        telemetryID: String? = nil,
        mixpanelID: String? = nil,
        sentryDSN: String? = nil,
        revenueCatID: String? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.userID = userID
        self.logger = logger
        self.superwallID = superwallID
        self.posthogAPIKey = posthogAPIKey
        self.telemetryID = telemetryID
        self.mixpanelID = mixpanelID
        self.sentryDSN = sentryDSN
        self.revenueCatID = revenueCatID
        self.userDefaults = userDefaults
    }
}