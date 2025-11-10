import Foundation

/// Normalized payloads returned from feature-flag providers such as PostHog.
public enum AnalyticsFeatureFlagPayload: Sendable, Equatable {
    case string(String)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case dictionary([String: AnalyticsFeatureFlagPayload])
    case array([AnalyticsFeatureFlagPayload])

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
        case let .dictionary(value):
            return value.mapValues { $0.anyValue }
        case let .array(value):
            return value.map { $0.anyValue }
        }
    }

    public init?(rawValue: Any) {
        switch rawValue {
        case let string as String:
            self = .string(string)
        case let bool as Bool:
            self = .bool(bool)
        case let int as Int:
            self = .int(int)
        case let double as Double:
            self = .double(double)
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                self = .bool(number.boolValue)
            } else if number.doubleValue.truncatingRemainder(dividingBy: 1).isZero {
                self = .int(number.intValue)
            } else {
                self = .double(number.doubleValue)
            }
        case let dictionary as [String: Any]:
            let converted = dictionary.compactMapValues { AnalyticsFeatureFlagPayload(rawValue: $0) }
            self = .dictionary(converted)
        case let array as [Any]:
            let converted = array.compactMap { AnalyticsFeatureFlagPayload(rawValue: $0) }
            self = .array(converted)
        default:
            return nil
        }
    }
}
