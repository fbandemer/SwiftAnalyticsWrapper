import Foundation

/// Helper enforcing naming best practices and providing safe ways to build
/// event identifiers.
public enum AnalyticsNamingRules {
    private static let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_")

    public static func validateCategory<C: AnalyticsCategory>(_ category: C) throws {
        try validate(component: category.rawValue, type: .category)
    }

    public static func validateObject(_ object: AnalyticsObject) throws {
        try validate(component: object, type: .object)
    }

    public static func composeName<C: AnalyticsCategory>(
        category: C,
        object: AnalyticsObject,
        verb: AnalyticsVerb
    ) throws -> String {
        try validateCategory(category)
        try validateObject(object)
        return "\(category.rawValue):\(object):\(verb.rawValue)"
    }

    /// Non-throwing helper for UI code. Logs a debug assertion instead of
    /// bubbling errors which would otherwise make SwiftUI view builders messy.
    public static func composeNameUnchecked<C: AnalyticsCategory>(
        category: C,
        object: AnalyticsObject,
        verb: AnalyticsVerb
    ) -> String {
        do {
            return try composeName(category: category, object: object, verb: verb)
        } catch {
            assertionFailure("Invalid analytics naming: \(error.localizedDescription)")
            return "\(category.rawValue):\(object):\(verb.rawValue)"
        }
    }

    private static func validate(component: String, type: AnalyticsNamingError.ComponentType) throws {
        guard !component.isEmpty else {
            throw AnalyticsNamingError.empty(type)
        }

        guard component == component.lowercased() else {
            throw AnalyticsNamingError.uppercaseCharacters(component: component)
        }

        for character in component {
            guard let scalar = character.unicodeScalars.first, allowedCharacters.contains(scalar) else {
                throw AnalyticsNamingError.invalidCharacters(component: component, rejected: character)
            }
        }
    }
}
