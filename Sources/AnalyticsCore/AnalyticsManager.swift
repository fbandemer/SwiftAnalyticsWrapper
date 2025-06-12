import Foundation
import OSLog

public protocol AnalyticsManager {
    var configuration: AnalyticsConfiguration { get }
    var logger: Logger { get }
    
    func initialize(with configuration: AnalyticsConfiguration)
    func track(event: AnalyticsEvent)
    func setUserID(_ userID: String, attributes: [String: Any]?)
    func setUserAttribute(key: String, value: String)
    func incrementAttribute(key: String, value: Double)
    func setSubscriptionStatus(active: Bool, key: String)
}