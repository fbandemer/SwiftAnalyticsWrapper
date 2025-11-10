import Foundation

/// Supported analytics attribute value types shared between modules.
public enum AnalyticsAttributeValue: Sendable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case date(Date)

    public var anyValue: Any {
        switch self {
        case let .string(value):
            return value
        case let .bool(value):
            return value
        case let .int(value):
            return value
        case let .double(value):
            return value
        case let .date(value):
            return value
        }
    }
}

public extension Dictionary where Key == String, Value == AnalyticsAttributeValue {
    func toAnyDictionary() -> [String: Any] {
        reduce(into: [:]) { partialResult, element in
            partialResult[element.key] = element.value.anyValue
        }
    }
}
