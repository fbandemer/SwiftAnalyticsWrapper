import Foundation
import Observation

/// Configuration needed to bootstrap a crash-reporting backend.
public struct CrashConfiguration: Sendable {
    public var dsn: String?
    public var environment: String
    public var enableScreenshots: Bool

    public init(dsn: String? = nil, environment: String = "production", enableScreenshots: Bool = true) {
        self.dsn = dsn
        self.environment = environment
        self.enableScreenshots = enableScreenshots
    }
}

/// Additional data that can be attached to crash reports.
public struct CrashAttachment: Sendable {
    public var filename: String
    public var data: Data
    public var contentType: String

    public init(filename: String, data: Data, contentType: String) {
        self.filename = filename
        self.data = data
        self.contentType = contentType
    }
}

/// Lightweight crash manager contract for feature modules.
public protocol CrashManaging: AnyObject {
    var configuration: CrashConfiguration { get }
    func start(with configuration: CrashConfiguration)
    func capture(error: Error, attachments: [CrashAttachment])
    func log(_ message: String)
}

/// Observable base crash manager to allow SwiftUI environment injection.
@Observable
open class CrashManager: CrashManaging {
    public private(set) var configuration: CrashConfiguration

    public init(configuration: CrashConfiguration = .init()) {
        self.configuration = configuration
    }

    open func start(with configuration: CrashConfiguration) {
        self.configuration = configuration
    }

    open func capture(error: Error, attachments: [CrashAttachment] = []) {
        // Default no-op.
    }

    open func log(_ message: String) {
        // Default no-op.
    }
}
