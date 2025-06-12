import Foundation

public struct AnalyticsEvent {
    public let name: String
    public let parameters: [String: Any]
    public let value: Double?
    
    public init(name: String, parameters: [String: Any] = [:], value: Double? = nil) {
        self.name = name
        self.parameters = parameters
        self.value = value
    }
    
    public static func create(
        category: String,
        object: String,
        verb: String,
        parameters: [String: Any] = [:]
    ) -> AnalyticsEvent {
        return AnalyticsEvent(
            name: "\(category):\(object)_\(verb)",
            parameters: parameters
        )
    }
}