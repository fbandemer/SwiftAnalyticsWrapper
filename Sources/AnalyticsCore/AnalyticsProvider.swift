import Foundation

public protocol AnalyticsProvider {
    func initialize(configuration: AnalyticsConfiguration)
    func track(event: AnalyticsEvent)
    func identify(userID: String, attributes: [String: Any]?)
    func setUserAttribute(key: String, value: String)
    func incrementAttribute(key: String, value: Double)
}