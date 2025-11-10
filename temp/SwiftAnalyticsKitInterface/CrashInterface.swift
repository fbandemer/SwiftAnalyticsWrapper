import Dependencies

/// Struct-based client for crash reporting integrations.
public struct CrashClient: Sendable {
    public var configuration: @Sendable () -> CrashConfiguration
    public var start: @Sendable (_ configuration: CrashConfiguration) -> Void
    public var capture: @Sendable (_ error: Error, _ attachments: [CrashAttachment]) -> Void
    public var log: @Sendable (_ message: String) -> Void

    public init(
        configuration: @escaping @Sendable () -> CrashConfiguration,
        start: @escaping @Sendable (_ configuration: CrashConfiguration) -> Void,
        capture: @escaping @Sendable (_ error: Error, _ attachments: [CrashAttachment]) -> Void,
        log: @escaping @Sendable (_ message: String) -> Void
    ) {
        self.configuration = configuration
        self.start = start
        self.capture = capture
        self.log = log
    }
}

extension CrashClient: TestDependencyKey {
    public static let testValue: Self = .empty
}

public extension DependencyValues {
    var crashClient: CrashClient {
        get { self[CrashClient.self] }
        set { self[CrashClient.self] = newValue }
    }
}
