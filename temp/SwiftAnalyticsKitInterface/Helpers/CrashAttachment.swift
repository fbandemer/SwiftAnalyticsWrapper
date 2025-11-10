import Foundation

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
