import AnalyticsManager
import Foundation
import SwiftAnalyticsKitInterface
import Testing

struct ReviewClientTests {
    private let day: TimeInterval = 24 * 60 * 60

    @Test
    func testShouldPresentAfterMinimumAppOpens() {
        let suiteName = "ReviewClientTests.testShouldPresentAfterMinimumAppOpens"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)

        let configuration = ReviewClient.Configuration(
            minimumAppOpensBeforePrompt: 2,
            minimumDaysBetweenPrompts: 7,
            maximumPromptCount: 3
        )
        var currentDate = Date()

        let client = ReviewClient.default(
            configuration: configuration,
            userDefaults: userDefaults,
            now: { currentDate }
        )

        var decision = client.shouldPresentReviewPrompt()
        #expect(!decision.shouldPresent)
        #expect(decision.reason == .minimumAppOpensNotReached)

        client.trackAppOpen()
        #expect(client.appOpenCount() == 1)
        decision = client.shouldPresentReviewPrompt()
        #expect(!decision.shouldPresent)
        #expect(decision.reason == .minimumAppOpensNotReached)

        client.trackAppOpen()
        #expect(client.appOpenCount() == 2)
        decision = client.shouldPresentReviewPrompt()
        #expect(decision.shouldPresent)
        #expect(decision.reason == .eligible)
    }

    @Test
    func testCooldownBlocksPromptUntilMinimumDaysPass() {
        let suiteName = "ReviewClientTests.testCooldownBlocksPromptUntilMinimumDaysPass"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)

        let configuration = ReviewClient.Configuration(
            minimumAppOpensBeforePrompt: 1,
            minimumDaysBetweenPrompts: 5,
            maximumPromptCount: 3
        )
        let startDate = Date()
        var currentDate = startDate

        let client = ReviewClient.default(
            configuration: configuration,
            userDefaults: userDefaults,
            now: { currentDate }
        )

        client.trackAppOpen()
        var decision = client.shouldPresentReviewPrompt()
        #expect(decision.shouldPresent)
        #expect(decision.reason == .eligible)

        client.trackReviewPrompt()
        #expect(client.reviewPromptCount() == 1)
        #expect(client.appOpenCount() == 0)

        currentDate = startDate.addingTimeInterval(2 * day)
        client.trackAppOpen()
        decision = client.shouldPresentReviewPrompt()
        #expect(!decision.shouldPresent)
        #expect(decision.reason == .timeBorderNotCrossed)

        currentDate = startDate.addingTimeInterval(6 * day)
        client.trackAppOpen()
        #expect(client.appOpenCount() == 2)
        decision = client.shouldPresentReviewPrompt()
        #expect(decision.shouldPresent)
        #expect(decision.reason == .eligible)
    }

    @Test
    func testMaximumPromptCountPreventsFurtherPrompts() {
        let suiteName = "ReviewClientTests.testMaximumPromptCountPreventsFurtherPrompts"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)

        let configuration = ReviewClient.Configuration(
            minimumAppOpensBeforePrompt: 1,
            minimumDaysBetweenPrompts: 1,
            maximumPromptCount: 1
        )
        var currentDate = Date()

        let client = ReviewClient.default(
            configuration: configuration,
            userDefaults: userDefaults,
            now: { currentDate }
        )

        client.trackAppOpen()
        var decision = client.shouldPresentReviewPrompt()
        #expect(decision.shouldPresent)
        #expect(decision.reason == .eligible)
        client.trackReviewPrompt()
        #expect(client.reviewPromptCount() == 1)

        currentDate = currentDate.addingTimeInterval(3 * day)
        client.trackAppOpen()
        decision = client.shouldPresentReviewPrompt()
        #expect(!decision.shouldPresent)
        #expect(decision.reason == .maximumPromptCountReached)
        #expect(client.reviewPromptCount() == 1)
    }

    @Test
    func testSuccessThresholdAllowsPromptBeforeAppOpens() {
        let suiteName = "ReviewClientTests.testSuccessThresholdAllowsPromptBeforeAppOpens"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)

        let configuration = ReviewClient.Configuration(
            minimumAppOpensBeforePrompt: 1,
            minimumDaysBetweenPrompts: 5,
            maximumPromptCount: 3
        )
        let startDate = Date()
        var currentDate = startDate

        let client = ReviewClient.default(
            configuration: configuration,
            userDefaults: userDefaults,
            now: { currentDate }
        )

        userDefaults.set(2, forKey: "ReviewClient.successCount")
        #expect(client.appOpenCount() == 0)
        var decision = client.shouldPresentReviewPromptAfterSuccess()
        #expect(decision.shouldPresent)
        #expect(decision.reason == .eligible)
        #expect(userDefaults.integer(forKey: "ReviewClient.successCount") == 3)

        client.trackReviewPrompt()
        #expect(client.reviewPromptCount() == 1)

        currentDate = startDate.addingTimeInterval(2 * day)
        decision = client.shouldPresentReviewPromptAfterSuccess()
        #expect(!decision.shouldPresent)
        #expect(decision.reason == .timeBorderNotCrossed)
        #expect(userDefaults.integer(forKey: "ReviewClient.successCount") == 4)

        currentDate = startDate.addingTimeInterval(6 * day)
        decision = client.shouldPresentReviewPromptAfterSuccess()
        #expect(decision.shouldPresent)
        #expect(decision.reason == .eligible)
    }
}
