import SwiftAnalyticsKitInterface
import AnalyticsManagerTesting
import Foundation
import Testing
@testable import AnalyticsManager

struct AnalyticsManagerTests {
    @Test
    func namingRulesRejectUppercaseObject() {
        #expect(
            throws: AnalyticsNamingError.uppercaseCharacters(component: "DeleteButton")
        ) {
            try AnalyticsNamingRules.composeName(
                category: AnalyticsTestCategory.checkout,
                object: "DeleteButton",
                verb: .click
            )
        }
    }

    @Test
    func mockAnalyticsManagerRecordsTrackedEvents() throws {
        let mock = MockAnalyticsManager()
        let client = mock.client
        let event = try AnalyticsEvent(
            category: AnalyticsTestCategory.settings,
            object: "delete_account_button",
            verb: .click,
            properties: [
                "button_type": .string("danger")
            ]
        )

        client.track(event)

        #expect(mock.trackedEvents.count == 1)
        #expect(mock.trackedEvents.first?.name == "settings:delete_account_button:click")
    }

    @Test
    func handlePlacementRecordsAndCompletes() async {
        let mock = MockAnalyticsManager()
        mock.placementCompletionQueue = DispatchQueue(label: "mock.placement")
        let client = mock.client

        await withCheckedContinuation { continuation in
            client.handlePlacement("settings:advanced:view", ["cta": "advanced"]) {
                continuation.resume()
            }
        }

        #expect(mock.handledPlacements.count == 1)
        #expect(mock.handledPlacements.first?.name == "settings:advanced:view")
        #expect(mock.handledPlacements.first?.params["cta"] as? String == "advanced")
    }

    @Test
    func featureFlagOverridesExposeState() {
        let mock = MockFeatureFlagManager()
        let client = mock.client
        mock.overrides["paywall_v2"] = .init(
            isEnabled: true,
            variant: "treatment",
            payload: .string("copy_b")
        )

        #expect(client.isFeatureFlagEnabled("paywall_v2"))
        #expect(client.featureFlagVariant("paywall_v2") == "treatment")
        #expect(client.isFeatureFlagInVariant("paywall_v2", "treatment"))
        #expect(client.featureFlagPayloadIfEnabled("paywall_v2") == .string("copy_b"))
        #expect(client.featureFlagPayload("paywall_v2", "treatment") == .string("copy_b"))
    }
}
