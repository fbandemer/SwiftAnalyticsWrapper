import Foundation

/// Details used to identify and enrich the current analytics user.
public struct AnalyticsUserIdentity: Sendable {
    public var id: String
    public var email: String?
    public var pushToken: String?
    public var attributes: AnalyticsAttributes

    public init(
        id: String,
        email: String? = nil,
        pushToken: String? = nil,
        attributes: AnalyticsAttributes = [:]
    ) {
        self.id = id
        self.email = email
        self.pushToken = pushToken
        self.attributes = attributes
    }
}
