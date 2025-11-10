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
