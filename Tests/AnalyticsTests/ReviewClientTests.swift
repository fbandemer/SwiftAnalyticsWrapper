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

        #expect(!client.shouldPresentReviewPrompt())

        client.trackAppOpen()
        #expect(client.appOpenCount() == 1)
        #expect(!client.shouldPresentReviewPrompt())

        client.trackAppOpen()
        #expect(client.appOpenCount() == 2)
        #expect(client.shouldPresentReviewPrompt())
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
        #expect(client.shouldPresentReviewPrompt())

        client.trackReviewPrompt()
        #expect(client.reviewPromptCount() == 1)
        #expect(client.appOpenCount() == 0)

        currentDate = startDate.addingTimeInterval(2 * day)
        client.trackAppOpen()
        #expect(!client.shouldPresentReviewPrompt())

        currentDate = startDate.addingTimeInterval(6 * day)
        client.trackAppOpen()
        #expect(client.appOpenCount() == 2)
        #expect(client.shouldPresentReviewPrompt())
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
        #expect(client.shouldPresentReviewPrompt())
        client.trackReviewPrompt()
        #expect(client.reviewPromptCount() == 1)

        currentDate = currentDate.addingTimeInterval(3 * day)
        client.trackAppOpen()
        #expect(!client.shouldPresentReviewPrompt())
        #expect(client.reviewPromptCount() == 1)
    }
}
