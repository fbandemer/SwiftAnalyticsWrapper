import Foundation

/// Represents a single analytics event with optional metadata.
public struct AnalyticsEvent: Sendable {
    public let category: String
    public let object: AnalyticsObject
    public let verb: AnalyticsVerb
    public var properties: AnalyticsAttributes

    public var name: String {
        "\(category):\(object):\(verb.rawValue)"
    }

    public init<C: AnalyticsCategory>(
        category: C,
        object: AnalyticsObject,
        verb: AnalyticsVerb,
        properties: AnalyticsAttributes = [:]
    ) throws {
        try AnalyticsNamingRules.validateCategory(category)
        try AnalyticsNamingRules.validateObject(object)
        self.category = category.rawValue
        self.object = object
        self.verb = verb
        self.properties = properties
    }
}
