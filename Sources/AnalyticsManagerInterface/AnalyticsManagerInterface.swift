import Foundation
import Observation
import SwiftUI

/// Type-safe payload used for analytics calls.
public typealias AnalyticsAttributes = [String: AnalyticsAttributeValue]
public typealias AnalyticsObject = String
public typealias AnalyticsAction = () -> Void

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

/// SUPPORTED VERBS ---------------------------------------------------------
/// Events follow the {category}:{object}:{action} structure described in
/// "Simple Event Naming Conventions for Product Analytics" (Nov 2024).
/// Verbs are present tense, snake_case, and limited to this curated list to
/// keep analytics data readable across teams.
public enum AnalyticsVerb: String, CaseIterable, Sendable {
    case view
    case click
    case submit
    case create
    case add
    case delete
    case start
    case end
    case cancel
    case fail
    case send
    case invite
    case update
    case dismiss
}

/// Categories live in the app layer. Conform any enum to this protocol to make
/// it usable with the analytics interface while keeping the string raw value in
/// snake_case (e.g. `enum BillingCategory: String, AnalyticsCategory { case account_settings }`).
public protocol AnalyticsCategory: RawRepresentable, Sendable where RawValue == String {}

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

public extension Dictionary where Key == String, Value == AnalyticsAttributeValue {
    func toAnyDictionary() -> [String: Any] {
        reduce(into: [:]) { partialResult, element in
            partialResult[element.key] = element.value.anyValue
        }
    }
}

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

/// High-level switches required to bootstrap an analytics manager implementation.
public struct AnalyticsConfiguration: Sendable {
    public var loggerSubsystem: String
    public var loggerCategory: String
    public var superwallAPIKey: String?
    public var posthogAPIKey: String?
    public var revenueCatAPIKey: String?

    public init(
        loggerSubsystem: String = "",
        loggerCategory: String = "",
        superwallAPIKey: String? = nil,
        posthogAPIKey: String? = nil,
        revenueCatAPIKey: String? = nil
    ) {
        self.loggerSubsystem = loggerSubsystem
        self.loggerCategory = loggerCategory
        self.superwallAPIKey = superwallAPIKey
        self.posthogAPIKey = posthogAPIKey
        self.revenueCatAPIKey = revenueCatAPIKey
    }
}

/// Shared API that concrete analytics managers must implement.
public protocol AnalyticsManaging: AnyObject {
    var configuration: AnalyticsConfiguration { get }
    var isSuperwallEnabled: Bool { get }
    func configure(using configuration: AnalyticsConfiguration)
    func initializeIfNeeded(userDefaults: UserDefaults)
    func track(_ event: AnalyticsEvent)
    func setUserIdentity(_ identity: AnalyticsUserIdentity)
    func setUserAttribute(_ key: String, value: AnalyticsAttributeValue)
    func incrementUserAttribute(_ key: String, by value: Double)
    func setSubscriptionStatus(isActive: Bool, key: String)
    func handlePlacement(_ placement: String, params: [String: Any], completion: @escaping () -> Void)
    func makeCustomerCenterView() -> AnyView
}
