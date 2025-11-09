import XCTest
@testable import AnalyticsManager
import AnalyticsManagerInterface
import AnalyticsManagerTesting

final class AnalyticsManagerTests: XCTestCase {
    func testNamingRulesRejectUppercaseObject() {
        XCTAssertThrowsError(
            try AnalyticsNamingRules.composeName(
                category: AnalyticsTestCategory.checkout,
                object: "DeleteButton",
                verb: .click
            )
        ) { error in
            guard case AnalyticsNamingError.uppercaseCharacters = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testMockAnalyticsManagerRecordsTrackedEvents() throws {
        let mock = MockAnalyticsManager()
        let event = try AnalyticsEvent(
            category: AnalyticsTestCategory.settings,
            object: "delete_account_button",
            verb: .click,
            properties: [
                "button_type": .string("danger")
            ]
        )

        mock.track(event)

        XCTAssertEqual(mock.trackedEvents.count, 1)
        XCTAssertEqual(mock.trackedEvents.first?.name, "settings:delete_account_button:click")
    }

    func testHandlePlacementRecordsAndCompletes() {
        let mock = MockAnalyticsManager()
        mock.placementCompletionQueue = DispatchQueue(label: "mock.placement")
        let expectation = expectation(description: "placement completion")

        mock.handlePlacement("settings:advanced:view", params: ["cta": "advanced"]) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(mock.handledPlacements.count, 1)
        XCTAssertEqual(mock.handledPlacements.first?.name, "settings:advanced:view")
        XCTAssertEqual(mock.handledPlacements.first?.params["cta"] as? String, "advanced")
    }
}
