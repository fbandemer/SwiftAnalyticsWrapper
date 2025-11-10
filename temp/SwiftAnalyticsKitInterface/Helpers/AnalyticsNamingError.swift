import Foundation

/// Naming rule violations surfaced when composing events.
public enum AnalyticsNamingError: LocalizedError {
    case empty(ComponentType)
    case invalidCharacters(component: String, rejected: Character)
    case uppercaseCharacters(component: String)

    public enum ComponentType: String {
        case category
        case object
    }

    public var errorDescription: String? {
        switch self {
        case let .empty(type):
            return "Analytics \(type.rawValue) cannot be empty."
        case let .invalidCharacters(component, rejected):
            return "Analytics component '\(component)' includes unsupported character '\(rejected)'. Use lowercase letters, numbers, or underscores."
        case let .uppercaseCharacters(component):
            return "Analytics component '\(component)' must be snake_case (all lowercase)."
        }
    }
}
