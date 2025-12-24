import Dependencies
import Foundation
import SwiftAnalyticsKitInterface

public extension ReviewClient {
    static func `default`(
        configuration: Configuration = .default,
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current,
        now: @escaping () -> Date = Date.init
    ) -> Self {
        func hasMetMinimumDaysSincePrompt(_ lastPromptDate: Date?) -> Bool {
            guard let lastPromptDate else {
                return true
            }

            guard let daysSincePrompt = calendar.dateComponents(
                [.day],
                from: lastPromptDate,
                to: now()
            ).day else {
                return false
            }

            return daysSincePrompt >= configuration.minimumDaysBetweenPrompts
        }

        return Self(
            userDefaults: userDefaults,
            trackAppOpen: {
                let currentCount = userDefaults.integer(forKey: StorageKeys.appOpenCount)
                userDefaults.set(currentCount + 1, forKey: StorageKeys.appOpenCount)
            },
            trackReviewPrompt: {
                let currentCount = userDefaults.integer(forKey: StorageKeys.reviewPromptCount)
                userDefaults.set(currentCount + 1, forKey: StorageKeys.reviewPromptCount)
                userDefaults.set(now(), forKey: StorageKeys.lastReviewPromptDate)
                userDefaults.set(0, forKey: StorageKeys.appOpenCount)
            },
            lastReviewPromptDate: {
                userDefaults.object(forKey: StorageKeys.lastReviewPromptDate) as? Date
            },
            appOpenCount: {
                userDefaults.integer(forKey: StorageKeys.appOpenCount)
            },
            reviewPromptCount: {
                userDefaults.integer(forKey: StorageKeys.reviewPromptCount)
            },
            shouldPresentReviewPrompt: {
                let promptCount = userDefaults.integer(forKey: StorageKeys.reviewPromptCount)
                guard promptCount < configuration.maximumPromptCount else {
                    return false
                }

                let opens = userDefaults.integer(forKey: StorageKeys.appOpenCount)
                guard opens >= configuration.minimumAppOpensBeforePrompt else {
                    return false
                }

                let lastPromptDate = userDefaults.object(forKey: StorageKeys.lastReviewPromptDate) as? Date
                return hasMetMinimumDaysSincePrompt(lastPromptDate)
            },
            shouldPresentReviewPromptAfterSuccess: {
                let promptCount = userDefaults.integer(forKey: StorageKeys.reviewPromptCount)
                guard promptCount < configuration.maximumPromptCount else {
                    return false
                }

                let currentCount = userDefaults.integer(forKey: StorageKeys.successCount)
                let nextCount = currentCount + 1
                userDefaults.set(nextCount, forKey: StorageKeys.successCount)

                let lastPromptDate = userDefaults.object(forKey: StorageKeys.lastReviewPromptDate) as? Date
                guard let lastPromptDate else {
                    return nextCount >= 1
                }

                return hasMetMinimumDaysSincePrompt(lastPromptDate)
            }
        )
    }
}

extension ReviewClient: DependencyKey {
    public static let liveValue: ReviewClient = .default()
}

private enum StorageKeys {
    static let lastReviewPromptDate = "ReviewClient.lastReviewPromptDate"
    static let appOpenCount = "ReviewClient.appOpenCount"
    static let reviewPromptCount = "ReviewClient.reviewPromptCount"
    static let successCount = "ReviewClient.successCount"
}
