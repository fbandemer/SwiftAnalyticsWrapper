import Foundation
import PostHog
import SwiftAnalyticsKitInterface

public extension AnalyticsClient {
    /// Whether PostHog session replay is currently recording.
    static var isSessionReplayActive: Bool {
        #if os(iOS)
            return PostHogSDK.shared.isSessionReplayActive()
        #else
            return false
        #endif
    }

    /// Pauses or resumes PostHog session replay without ending the session.
    ///
    /// Screenshot-mode replay renders the key window about once a second. An app that draws a
    /// live map or runs a long foreground activity pauses replay for its duration and resumes
    /// the same session afterwards, so the recording before and after stays one replay.
    ///
    /// - Returns: whether replay is recording after the call.
    @discardableResult
    static func setSessionReplayPaused(_ paused: Bool) -> Bool {
        #if os(iOS)
            if paused {
                PostHogSDK.shared.stopSessionRecording()
            } else {
                PostHogSDK.shared.startSessionRecording(resumeCurrent: true)
            }
            return PostHogSDK.shared.isSessionReplayActive()
        #else
            return false
        #endif
    }
}
