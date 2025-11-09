import Foundation
import Observation

/// Observable base crash manager with empty behavior.
@Observable
open class EmptyCrashManager: CrashManaging {
    public private(set) var configuration: CrashConfiguration

    public init(configuration: CrashConfiguration = .init()) {
        self.configuration = configuration
    }

    open func start(with configuration: CrashConfiguration) {
        self.configuration = configuration
    }

    open func capture(error: Error, attachments: [CrashAttachment] = []) {
        // empty
    }

    open func log(_ message: String) {
        // empty
    }
}
