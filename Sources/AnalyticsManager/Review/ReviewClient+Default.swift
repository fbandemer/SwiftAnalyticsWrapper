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
        func cooldownDecision(lastPromptDate: Date?) -> (shouldPresent: Bool, reason: ReviewDecisionReason) {
            guard let lastPromptDate else {
                return (true, .eligible)
            }

            guard let daysSincePrompt = calendar.dateComponents(
                [.day],
                from: lastPromptDate,
                to: now()
            ).day else {
                return (false, .timeBorderNotCrossed)
            }

            guard daysSincePrompt >= configuration.minimumDaysBetweenPrompts else {
                return (false, .timeBorderNotCrossed)
            }

            return (true, .eligible)
        }

        func ensureFirstAppOpenDate() -> Date {
            if let firstAppOpenDate = userDefaults.object(forKey: StorageKeys.firstAppOpenDate) as? Date {
                return firstAppOpenDate
            }

            let firstAppOpenDate = now()
            userDefaults.set(firstAppOpenDate, forKey: StorageKeys.firstAppOpenDate)
            return firstAppOpenDate
        }

        func hasCompletedFirstDay() -> Bool {
            let firstAppOpenDate = ensureFirstAppOpenDate()
            guard let daysSinceFirstOpen = calendar.dateComponents(
                [.day],
                from: firstAppOpenDate,
                to: now()
            ).day else {
                return false
            }

            return daysSinceFirstOpen >= 1
        }

        return Self(
            userDefaults: userDefaults,
            trackAppOpen: {
                _ = ensureFirstAppOpenDate()
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
                    return (false, .maximumPromptCountReached)
                }

                let opens = userDefaults.integer(forKey: StorageKeys.appOpenCount)
                guard opens >= configuration.minimumAppOpensBeforePrompt else {
                    return (false, .minimumAppOpensNotReached)
                }

                guard hasCompletedFirstDay() else {
                    return (false, .timeBorderNotCrossed)
                }

                let lastPromptDate = userDefaults.object(forKey: StorageKeys.lastReviewPromptDate) as? Date
                return cooldownDecision(lastPromptDate: lastPromptDate)
            },
            shouldPresentReviewPromptAfterSuccess: {
                let promptCount = userDefaults.integer(forKey: StorageKeys.reviewPromptCount)
                guard promptCount < configuration.maximumPromptCount else {
                    return (false, .maximumPromptCountReached)
                }

                let currentCount = userDefaults.integer(forKey: StorageKeys.successCount)
                let nextCount = currentCount + 1
                userDefaults.set(nextCount, forKey: StorageKeys.successCount)

                guard hasCompletedFirstDay() else {
                    return (false, .timeBorderNotCrossed)
                }

                if currentCount == 0 {
                    return (true, .eligible)
                }

                let lastPromptDate = userDefaults.object(forKey: StorageKeys.lastReviewPromptDate) as? Date
                return cooldownDecision(lastPromptDate: lastPromptDate)
            }
        )
    }
}

extension ReviewClient: DependencyKey {
    public static let liveValue: ReviewClient = .default()
}

private enum StorageKeys {
    static let lastReviewPromptDate = "ReviewClient.lastReviewPromptDate"
    static let firstAppOpenDate = "ReviewClient.firstAppOpenDate"
    static let appOpenCount = "ReviewClient.appOpenCount"
    static let reviewPromptCount = "ReviewClient.reviewPromptCount"
    static let successCount = "ReviewClient.successCount"
}
