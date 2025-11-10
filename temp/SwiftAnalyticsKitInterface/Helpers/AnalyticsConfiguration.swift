import Foundation

/// High-level switches required to bootstrap an analytics manager implementation.
public struct AnalyticsConfiguration: Sendable {
    public var loggerSubsystem: String
    public var loggerCategory: String
    public var superwallAPIKey: String
    public var posthogAPIKey: String
    public var revenueCatAPIKey: String

    public init(
        loggerSubsystem: String = "",
        loggerCategory: String = "",
        superwallAPIKey: String = "",
        posthogAPIKey: String = "",
        revenueCatAPIKey: String = ""
    ) {
        self.loggerSubsystem = loggerSubsystem
        self.loggerCategory = loggerCategory
        self.superwallAPIKey = superwallAPIKey
        self.posthogAPIKey = posthogAPIKey
        self.revenueCatAPIKey = revenueCatAPIKey
    }
}
