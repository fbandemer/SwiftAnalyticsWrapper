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
